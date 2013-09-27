#!/bin/sh

set -e

setup_debian() {
  sudo apt-get -q -y install wget
  which lsb_release || sudo apt-get -q -y install lsb-release
  codename=$(lsb_release -c | awk '{print($2)}')
  if type prepare_$codename >/dev/null 2>&1; then
    prepare_$codename
  else
    echo "WARNING: no specific preparation steps for $codename"
  fi

  sudo apt-get -q -y install wget
  if [ ! -f /etc/apt/sources.list.d/analizo.list ]; then
    echo "deb http://analizo.org/download/ ./" | sudo sh -c 'cat > /etc/apt/sources.list.d/analizo.list'
    wget -O - http://analizo.org/download/signing-key.asc | sudo apt-key add -
    sudo apt-get update
  fi

  packages=$(sed -e '1,/^Build-Depends-Indep:/ d; /^\S/,$ d; s/,//; s/(.*$//' debian/control)
  sudo apt-get -q -y -f install $packages
  sudo apt-get -q -y install libfile-sharedir-install-perl
}

prepare_squeeze() {

  if ! test -f  /etc/apt/sources.list.d/squeeze-backports.list; then
    echo 'deb http://backports.debian.org/debian-backports squeeze-backports main' > /etc/apt/sources.list.d/squeeze-backports.list
    apt-get update
  fi
  apt-get install -q -y -t squeeze-backports rubygems

  (gem list | grep cucumber) || sudo gem install --no-ri --no-rdoc cucumber
  (gem list | grep rspec) || sudo gem install --no-ri --no-rdoc rspec

  apt-get install -q -y equivs
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
