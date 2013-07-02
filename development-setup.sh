#!/bin/sh

set -e

setup_debian() {
	sudo apt-get install wget gnupg
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
    #echo "deb http://debian.joenio.me unstable/" | sudo sh -c 'cat >> /etc/apt/sources.list.d/analizo.list'
    #wget -O - http://debian.joenio.me/signing.asc | sudo apt-key add -
    sudo apt-get update
  fi
  which apt-file || sudo apt-get -q -y install apt-file
  sudo apt-file update

  sudo apt-get -q -y install dh-make-perl libdist-zilla-perl
  packages=$(dh-make-perl locate $(dzil authordeps) | grep 'package$' | grep ' is in ' | sed 's/.\+is in \(.\+\) package/\1/')
  sudo apt-get -q -y -f install $packages

  packages=$(dh-make-perl locate $(dzil listdeps) | grep 'package$' | grep ' is in ' | sed 's/.\+is in \(.\+\) package/\1/')
  sudo apt-get -q -y -f install $packages

  # `dzil externaldeps` foi submetido ao upstream, aguardando aprovação
  # https://github.com/mjgardner/Dist-Zilla-Plugin-RequiresExternal/pull/5
  # packages=$(dzil externaldeps)
  # sudo apt-get -q -y -f install $packages
  # instalando dependencias "na mao" enquanto PullRequest n tem resposta
  sudo apt-get install -q -y -f doxyparse sloccount sqlite3 man pandoc

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
