#!/bin/sh

set -e

setup_debian() {
  sudo apt-get -q -y install wget gnupg
  which lsb_release || sudo apt-get -q -y install lsb-release
  codename=$(lsb_release -c | awk '{print($2)}')
  if type prepare_$codename >/dev/null 2>&1; then
    prepare_$codename
  else
    echo "WARNING: no specific preparation steps for $codename"
  fi

  if [ ! -f /etc/apt/sources.list.d/analizo.list ]; then
    which wget || sudo apt-get -q -y install wget
    which gpg || sudo apt-get -q -y install gnupg
    echo "deb http://www.analizo.org/download/ ./" | sudo sh -c 'cat > /etc/apt/sources.list.d/analizo.list'
    wget -O - http://www.analizo.org/download/signing-key.asc | sudo apt-key add -
  fi
  which apt-file || sudo apt-get -q -y install apt-file
  sudo apt-get update
  sudo apt-file update

  sudo apt-get -q -y install dh-make-perl libdist-zilla-perl

  if ! which cpanm; then
    echo "*** cpanm NOT FOUND ***"
    echo "installing cpanm..." 1>&2
    sudo apt-get -q -y install cpanminus
  fi

  packages=$(locate_package $(dzil authordeps))
  sudo apt-get -q -y -f install $packages
  dzil authordeps --missing | cpanm --sudo --notest

  packages=$(locate_package $(dzil listdeps))
  sudo apt-get -q -y -f install $packages
  dzil listdeps --missing | cpanm --sudo --notest

  packages=$(dzil externaldeps)
  sudo apt-get -q -y -f install $packages
}

locate_package() {
  packages=
  for module in $@; do
    package=$(dh-make-perl locate $module | grep 'package$' | grep ' is in ' | sed 's/.\+is in \(.\+\) package/\1/')
    packages="$packages $package"
  done
  echo $packages
}

prepare_ubuntu() {
  if ! grep -q ZeroMQ Makefile.PL; then
    # only needed while we depend on ZeroMQ
    return
  fi
  apt-get install -q -y libzeromq-perl
}

prepare_precise() {
  prepare_ubuntu
}

prepare_quantal() {
  prepare_ubuntu
}

prepare_trusty() {
  prepare_ubuntu
}

# FIXME share data with Makefile.PL/dist.ini
needed_programs='
  cpanm
  git
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
  dzil listdeps | cpanm
}

if [ ! -f ./bin/analizo ]; then
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
