# doxyparse
echo 'deb http://analizo.org/download/ ./' | sudo tee /etc/apt/sources.list.d/analizo.list
wget -O - http://analizo.org/download/signing-key.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install doxyparse
sudo rm -rf /etc/apt/sources.list.d/analizo.list
sudo apt-get update

# rest of non-perl deps
sudo apt-get install git sloccount sqlite3 man pkg-config uuid-dev rake ruby-rspec libmagic-dev

# libraries needed to build ZeroMQ. Note libzmq3-dev comes from the zeromq PPA
# and not from official repos - you should not use that package name anywhere else
sudo apt-get install uuid-dev libzmq3-dev

if ! cpanm --installdeps --notest --verbose .; then
  cat /home/travis/.cpanm/build.log
  exit 1
fi