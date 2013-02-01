#!/bin/sh

set -e

setup_debian() {
  apt-get install devscripts equivs wget
  if [ ! -f /etc/apt/sources.list.d/analizo.list ]; then
    echo 'deb http://analizo.org/download/ ./' > /etc/apt/sources.list.d/analizo.list
    wget -O - http://analizo.org/download/signing-key.asc | apt-key add -
    apt-get update
  fi
  mk-build-deps -i -r -s sudo
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
