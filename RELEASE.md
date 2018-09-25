# Rough instructions for releasing packages

* make the code ready
* update VERSION in lib/Analizo.pm, commit
* write changelog in CHANGELOG.md and debian/changelog, commit
* git push
* release (see "Release task" below)
* build Debian package (see "Debian package" below)
* upload package to repository (see analizo.github.io/README.md for instructions)
* update analizo.org site to point to the newer version

### Release task

```console
dzil release
```

* this task will run all tests
* build a tar.gz package and upload to CPAN
* create and push git tag to GitHub

### Debian package

Please install Dist::Zilla::Deb to build Debian package.

```console
dzil debuild
```

To skip tests running during building package run:

```console
DEB_BUILD_OPTIONS=nocheck dzil debuild
```
