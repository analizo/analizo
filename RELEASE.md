# Rough instructions for releasing packages

* make the code ready
* update VERSION in lib/Analizo.pm, commit
* build package (see Release task below)
* upload tar.gz package do GitHub and CPAN
* build and upload Debian package to repository

### Release task

```console
dzil release
```

`release` task will do:

* run all tests
* build a tar.gz package
* create and push git tag
