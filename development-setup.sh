#!/bin/sh

set -e

setup_debian() {
  apt-get -q -y install wget
  which lsb_release || apt-get -q -y install lsb-release
  codename=$(lsb_release -c | awk '{print($2)}')
  type prepare_$codename >/dev/null 2>&1
  if [ $? -eq  0 ]; then
    prepare_$codename
  fi

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

prepare_squeeze() {

  if ! test -f  /etc/apt/sources.list.d/squeeze-backports.list; then
    echo 'deb http://backports.debian.org/debian-backports squeeze-backports main' > /etc/apt/sources.list.d/squeeze-backports.list
    apt-get update
  fi
  apt-get install -q -y -t squeeze-backports rubygems

  (gem list | grep rspec) || sudo gem install --no-ri --no-rdoc rspec

  apt-get install -q -y equivs
  for fakepkg in ruby-rspec; do
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

prepare_wheezy() {
  if ! grep -q ZeroMQ Makefile.PL; then
    # only needed while we depend on ZeroMQ
    return
  fi
  dpkg-query --show libzeromq-perl && return
  apt-get install -q -y libzeromq-perl && return # on we can `apt-get install`
  arch=$(dpkg-architecture -qDEB_HOST_ARCH)
  libzeromq=libzeromq-perl_0.23-1_$arch.deb
  wget -O "/tmp/$libzeromq" "http://analizo.org/wheezy/$libzeromq"
  dpkg --unpack "/tmp/$libzeromq"
  apt-get -q -y -f install
}

prepare_precise() {
  if ! grep -q ZeroMQ Makefile.PL; then
    # only needed while we depend on ZeroMQ
    return
  fi
  apt-get install -q -y libzeromq-perl
}
prepare_quantal() {
  if ! grep -q ZeroMQ Makefile.PL; then
    # only needed while we depend on ZeroMQ
    return
  fi
  apt-get install -q -y libzeromq-perl
}

# FIXME share data with Makefile.PL
needed_programs='
  cpanm
  doxyparse
  git
  ruby
  sloccount
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
