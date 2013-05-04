# doxyparse
echo 'deb http://analizo.org/download/ ./' > /etc/apt/sources.list.d/analizo.list
wget -O - http://analizo.org/download/signing-key.asc | apt-key add -
apt-get update
apt-get install doxyparse
rm -rf /etc/apt/sources.list.d/analizo.list
apt-get update

# rest of non-perl deps
apt-get install git sloccount sqlite3 man pkg-config uuid-dev rake cucumber ruby-rspec
