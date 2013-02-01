#!/bin/sh

set -e

setup_debian() {
  debian_squeeze_hack

  apt-get -q -y install devscripts equivs wget
  if [ ! -f /etc/apt/sources.list.d/analizo.list ]; then
    echo 'deb http://analizo.org/download/ ./' > /etc/apt/sources.list.d/analizo.list
    wget -O - http://analizo.org/download/signing-key.asc | apt-key add -
    apt-get update
  fi
  rm -f analizo-build-deps*.deb
  mk-build-deps
  sudo dpkg --unpack analizo-build-deps*.deb
  sudo apt-get -q -y -f install
}

debian_squeeze_hack() {
  which lsb_release || apt-get -q -y install lsb-release
  if ! lsb_release -c | grep -i squeeze; then
    return
  fi

  (gem list | grep cucumber) || sudo gem install cucumber
  (gem list | grep rspec) || sudo gem install rspec
  ln -s $(ruby -rubygems -e 'puts Gem.bindir')/* /usr/local/bin

  for fakepkg in cucumber ruby-rspec; do
    (
      echo "Section: misc"
      echo "Priority: optional"
      echo "Standards-Version: 3.6.2"
      echo
      echo "Package: ${fakepkg}"
    ) > /tmp/${fakepkg}.equivs
    (cd /tmp/ && equivs-build ${fakepkg}.equivs && dpkg -i ${fakepkg}_1.0_all.deb)
  done
}

# FIXME share data with Makefile.PL
needed_programs='
  cpanm
  doxyparse
  git
  ruby
  sloccount
  cucumber
  rake
  rspec
  sqlite3
  man
  pkg-config
'

needed_libraries='
  uuid
  libzmq
'

check_non_perl_dependencies() {
  failed=false

  for program in $needed_programs; do
    printf "Looking for $program ... "
    if ! which $program; then
      echo "*** $program NOT FOUND *** "
      failed=true
    fi
  done

  for package in $needed_libraries; do
    printf "Looking for $package ... "
    if pkg-config $package; then
      echo OK
    else
      echo "*** ${package}-dev NOT FOUND ***"
      failed=true
    fi
  done

  if [ "$failed" = 'true' ]; then
    echo
    echo "ERROR: missing dependencies"
    echo "See HACKING for tips on how to install missing dependencies"
    exit 1
  fi
}

setup_generic() {
  check_non_perl_dependencies
  cpanm --installdeps .
}

if [ ! -f ./analizo ]; then
  echo "Please run this script from the root of Analizo sources!"
  exit 1
fi

force_generic=false
if [ "$1" = '--generic' ]; then
  force_generic=true
fi

if [ -x /usr/bin/dpkg -a -x /usr/bin/apt-get -a "$force_generic" = false ]; then
  setup_debian
else
  setup_generic
fi
