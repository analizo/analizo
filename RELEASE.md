# Rough instructions for releasing packages

* make the code ready
* update VERSION in lib/Analizo.pm, commit
* write changelog in CHANGELOG.md and debian/changelog, commit
* build package (see "Release task" below)
* build and upload Debian package to repository (see "Debian package" below)
* update analizo.org site to point to the newer version

### Release task

```console
dzil release
```

`release` task will do:

* run all tests
* build a tar.gz package and upload to CPAN
* create and push git tag to GitHub

### Debian package

Please install Dist::Zilla::Deb to build Debian package.

```console
dzil debuild
```
