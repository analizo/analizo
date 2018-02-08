# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[1.20.0]: https://github.com/analizo/analizo/compare/1.19.1...1.20.0
[1.20.1]: https://github.com/analizo/analizo/compare/1.20.0...1.20.1
[1.20.2]: https://github.com/analizo/analizo/compare/1.20.1...1.20.2
[1.20.3]: https://github.com/analizo/analizo/compare/1.20.2...1.20.3
[1.20.4]: https://github.com/analizo/analizo/compare/1.20.3...1.20.4
[1.20.5]: https://github.com/analizo/analizo/compare/1.20.4...1.20.5
[1.20.6]: https://github.com/analizo/analizo/compare/1.20.5...1.20.6
[1.20.7]: https://github.com/analizo/analizo/compare/1.20.6...1.20.7
