# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added new tool files-graph to output graph among files in DOT format

### Removed
- The evolution-matrix visualization tool removed
- The dsm visualization tool removed

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

[Unreleased]: https://github.com/analizo/analizo/compare/1.22.0...HEAD
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
