# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.20.2] - 2018-01-06

### Added

- New dependencies: Alien::Doxyparse Alien::SLOCCount

### Fixed

- Avoid warnings about YAML duplicate map key "inherits"

## [1.20.1] - 2018-01-02

### Added

- Changelog based on "Keep a Changelog" project

### Changed

- Copyright holder name and email
- Development documentation updated

### Fixed

- Dist::Zilla::Deb `debuild` task to build Debian package
- Declaring missing Debian dependencies

## [1.20.0] - 2017-12-29

### Added

- Source code metrics documentation
- Dockerfile added
- Support for C# (CSharp)
- More automated tests

### Changed

- Doxyparse Extractor uses YAML output
- Depends on Doxyparse 1.8.14+
- Build process migrated from Rake to Dist::Zilla
- Migrate from ZeroMQ to ZMQ::FFI

### Removed

- CLANG Extractor removed
- Security metrics provided by CLANG Extractor removed
- Analizo site source code moved to new repository
- Ruby dependency removed

### Fixed

- Fixed Docker setup to run tests on Travis
- Script development-setup.sh fixed
- Running of a single acceptance Cucumber test fixed

[1.20.0]: https://github.com/analizo/analizo/compare/1.19.1...1.20.0
[1.20.1]: https://github.com/analizo/analizo/compare/1.20.0...1.20.1
[1.20.2]: https://github.com/analizo/analizo/compare/1.20.1...1.20.2
