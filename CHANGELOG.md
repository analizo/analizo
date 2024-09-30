# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- (for new features)

### Changed
- (for changes in existing functionality)

### Deprecated
- (for soon-to-be removed features)

### Removed
- (for now removed features)

### Fixed
- (for any bug fixes)

### Security
- (in case of vulnerabilities)

## [1.25.5] - 2024-09-30

### Changed
- declare Graph::Writer::Dot 2.09 requirement on Dist::Zilla dist.ini file

### Security
- replace `system("command $arg")` by `system("command", $arg)` to avoids invoking potentially dangerous shell commands

## [1.25.4] - 2022-08-21

### Fixed
- fix Analizo::Metric::AfferentConnections POD syntax error
- add new recommended test dependency Test::Pod

## [1.25.3] - 2022-08-20

### Added
- add document on how to run Analizo with Docker

### Changed
- create variable $TEMP before run Doxyparse
- change copyright holder name to use fullname
- enrich samples copyright and licensing notices
- rename master branch to main
- add `tar` flag to avoid changing files ownership when run as root

### Fixed
- fix install documentation
- fix reference paper for ACC metric
- remove duplicity of authors names in .mailmap file
- fix misspelling and spelling test
- rm shebang from bash-completion

## [1.25.2] - 2022-07-22

### Changed
- change debian stretch to buster on dockerfile

### Removed
- get rid of travis-ci (preparing to migrate to gitlab)

### Fixed
- make sure Graph::TransitiveClosure::Matrix is loaded

## [1.25.1] - 2021-01-05

### Fixed
- error cpantester "can't locate local::lib"
- ignore prototype functions to fix NOM metric

## [1.25.0] - 2021-01-04

### Changed
- Depends on doxyparse 1.9.0 (provided by Alien::Doxyparse 0.17)
- Depends on DBI 1.635+

### Removed
- Drop YAML dependency, using YAML::XS instead

### Fixed
- Add samples to improve testcases for errors on YAML syntax
- Add freebsd support
  * using shebang `/usr/bin/env perl` instead of `/usr/bin/perl`
  * fixed args for manpage command line tool on freebsd
  * documented steps on how to run testcases on freebsd

## [1.24.0] - 2020-04-15

### Changed
- Use local::lib on t/festures.t
- Depends on doxyparse 1.8.18 (provided by Alien::Doxyparse 0.16)
- Update copyright year 2014-2019
- Improve ACCM metric documentation
- Update bash completion script
- Use Digest::SHA instead of `sha1sum`

### Removed
- Removed Debian package source files

### Fixed
- Fix warnings about uninitialized value on tests
- Removed failing Parallelel unit testcase
- Fixed some spelling errors
- Fixed documentation about `--modules` param on `analizo graph`
- Fixed parsing method signature on newer doxyparse YAML output
- Fixed warning about Cucumber TestBuilder deprecation
- Declared requirement for Test::BDD::Cucumber::Harness::TAP

## [1.23.0] - 2019-08-10

### Added
- Added new tool files-graph to output graph among files in DOT format
- Add Ubuntu 16 install instructions on documentation

### Changed
- Depends on doxyparse 1.8.15 provided by Alien::Doxyparse 0.13
- Stores cache on distinct dirs for each Analizo version
- Improve ACC metric description on documentation

### Fixed
- Added test for void arguments on C code
- Fix tests to run on right place `t/samples/sample_basic/c/`
- Added missing prereq Graph::Writer::Dot as suggested by CPANTS
- Added atomated tests for httpd-2.4.38 errors
- Added samples for bug parsing kdelibs project

### Removed
- Removed the evolution-matrix visualization tool
- Removed the dsm visualization tool

## [1.22.0] - 2018-09-25

### Removed
- Removed global metric `total_eloc`
- Removed dependency for `sloccount` external tool

### Changed
- Development setup installs Doxyparse from latest source master branch
- Improved the performance for ACC metric calculation

### Fixed
- Update to the newer Doxyparse 1.8.14-7 (fix invalid YAML with "\" char)
- Invalid references to function
- Limit Doxyparse YAML output identifiers to 1024 chars

## [1.21.0] - 2018-04-30

### Added
- Added documentation about the meaning of 0 (zero) value for metrics
- Added documentation for C# language support
- Added tests for Java Enumerations and Java Generics with Wildcards<?>
- Added tests for Doxyparse bug parsing mlpack source-code

### Changed
- authors listed on 'Signed-off-by' added to AUTHORS file
- Improving performance by using module `YAML::XS` instead of `YAML`
- Improving performance avoid calculating `Graph` every time

### Deprecated
- Global metric `total_eloc` (Total Effective Lines of Code) is going to be removed next release

### Removed
- Removed dependency for module `Moo`
- Removed dependency for pragma `base`

### Fixed
- Fix documentation for LCOM4 metric
- Fix missing dependency for `Class::Inspector`
- Removing cache after every test execution

## [1.20.8] - 2018-03-23

### Added
- Auto generate META.json using dzil plugin MetaJSON

### Fixed
- Changed markdown syntax to fix pandoc html transforming
- Tests depends on File::Slurp
- Env::Path is required at runtime

### Removed
- Removed dependency for Method::Signatures

## [1.20.7] - 2018-02-07

### Changed
- Change development script to install CPAN modules without sudo.

### Fixed
- Fix tests to run under Perl located in different paths.

### Removed
- Removed external dependency for `man`.

## [1.20.6] - 2018-02-06

### Changed
- Added doxyparse as Debian dependency (hardcoded).
- Added sloccount as Debian dependency (hardcoded).

### Deprecated
- Analizo visualization tools `dsm` and `evolution-matrix` are going to be removed from Analizo, the tools will be refactored or just removed.

### Removed
- Removed external dependency for `sqlite3`.
- Removed external dependency for `man`.

## [1.20.5] - 2018-02-03

### Changed
- Depends on doxyparse 1.8.14-4 provided by Alien::Doxyparse 0.06.

### Fixed
- Fix dependencies to run test suite on cpantesters.
- Fix travis-ci build.

## [1.20.4] - 2018-02-02

### Fixed
- Fix YAML duplicate key.
- Fix bin PATH for doxyparse and sloccount external tools.
- Fix missing dependencie for App::Cmd.

## [1.20.3] - 2018-01-26

### Changed
- Test suite refactored (package namespace t::Analizo renamed to Test::Analizo).

## [1.20.2] - 2018-01-06

### Added
- New dependencies: Alien::Doxyparse Alien::SLOCCount.

### Fixed
- Avoid warnings about YAML duplicate map key "inherits".

## [1.20.1] - 2018-01-02

### Added
- Changelog based on "Keep a Changelog" project.

### Changed
- Copyright holder name and email.
- Development documentation updated.

### Fixed
- Dist::Zilla::Deb `debuild` task to build Debian package.
- Declaring missing Debian dependencies.

## [1.20.0] - 2017-12-29

### Added
- Source code metrics documentation.
- Dockerfile added.
- Support for C# (CSharp).
- More automated tests.

### Changed
- Doxyparse Extractor uses YAML output.
- Depends on Doxyparse 1.8.14+.
- Build process migrated from Rake to Dist::Zilla.
- Migrate from ZeroMQ to ZMQ::FFI.

### Removed
- CLANG Extractor removed.
- Security metrics provided by CLANG Extractor removed.
- Analizo site source code moved to new repository.
- Ruby dependency removed.

### Fixed
- Fixed Docker setup to run tests on Travis.
- Script development-setup.sh fixed.
- Running of a single acceptance Cucumber test fixed.

[Unreleased]: https://github.com/analizo/analizo/compare/1.25.5...HEAD
[1.25.5]: https://github.com/analizo/analizo/compare/1.25.4...1.25.5
[1.25.4]: https://github.com/analizo/analizo/compare/1.25.3...1.25.4
[1.25.3]: https://github.com/analizo/analizo/compare/1.25.2...1.25.3
[1.25.2]: https://github.com/analizo/analizo/compare/1.25.1...1.25.2
[1.25.1]: https://github.com/analizo/analizo/compare/1.25.0...1.25.1
[1.25.0]: https://github.com/analizo/analizo/compare/1.24.0...1.25.0
[1.24.0]: https://github.com/analizo/analizo/compare/1.23.0...1.24.0
[1.23.0]: https://github.com/analizo/analizo/compare/1.22.0...1.23.0
[1.22.0]: https://github.com/analizo/analizo/compare/1.21.0...1.22.0
[1.21.0]: https://github.com/analizo/analizo/compare/1.20.8...1.21.0
[1.20.8]: https://github.com/analizo/analizo/compare/1.20.7...1.20.8
[1.20.7]: https://github.com/analizo/analizo/compare/1.20.6...1.20.7
[1.20.6]: https://github.com/analizo/analizo/compare/1.20.5...1.20.6
[1.20.5]: https://github.com/analizo/analizo/compare/1.20.4...1.20.5
[1.20.4]: https://github.com/analizo/analizo/compare/1.20.3...1.20.4
[1.20.3]: https://github.com/analizo/analizo/compare/1.20.2...1.20.3
[1.20.2]: https://github.com/analizo/analizo/compare/1.20.1...1.20.2
[1.20.1]: https://github.com/analizo/analizo/compare/1.20.0...1.20.1
[1.20.0]: https://github.com/analizo/analizo/compare/1.19.1...1.20.0
