# Rough instructions for releasing packages

* make the code ready
  * all tests are passing on linux, freebsd and any other supported platform
* make sure VERSION in lib/Analizo.pm is correct
* update CHANGELOG.md, commit
* git push
* run `dzil release` (see "Release task" below for details)
* update Debian package (see "Debian package" below)
* update analizo.org site to point to the newer version
* update VERSION in lib/Analizo.pm to the next version, commit

### Release task

The Dist::Zilla task `dzil release` do:

* run all tests
* build a tar.gz package and upload to CPAN
* create and push git tag to GitHub

### Debian package

Analizo has oficial Debian package and it's managed at Debian Perl Group
umbrella:

* https://salsa.debian.org/perl-team/modules/packages/analizo/

Please update Debian package on every Analizo release.
