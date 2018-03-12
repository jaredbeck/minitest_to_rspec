# Change Log

This project follows [semver 2.0.0][1] and the recommendations
of [keepachangelog.com][2].

## Unreleased

### Breaking Changes

- None

### Added

- [#21](https://github.com/jaredbeck/minitest_to_rspec/pull/21) -
  convert `setup`/`teardown` methods to `before`/`after` blocks
- [#18](https://github.com/jaredbeck/minitest_to_rspec/pull/18) -
  Support namespaced exceptions for assert_raise[s]

### Fixed

- None

## 0.11.0 (2017-11-10)

### Breaking Changes

- None

### Added

- [#15](https://github.com/jaredbeck/minitest_to_rspec/pull/15) -
  Support mocha stubs without returns
- [#16](https://github.com/jaredbeck/minitest_to_rspec/pull/16) -
  Convert `should` to `it`

### Fixed

- None

## 0.10.2 (2017-11-09)

### Breaking Changes

- None

### Added

- [#20](https://github.com/jaredbeck/minitest_to_rspec/pull/20) -
  Support `refute_raise[s]`

### Fixed

- [#12](https://github.com/jaredbeck/minitest_to_rspec/issues/12) -
  Only covert methods whose name begins with `test_`

## 0.10.1 (2017-11-04)

### Breaking Changes

- None

### Added

- None

### Fixed

- [#10](https://github.com/jaredbeck/minitest_to_rspec/pull/10) - Lift
  version constraint on sexp_processor

## 0.10.0 (2017-11-01)

### Breaking Changes

- Drop support for ruby < 2.3 so we can use frozen_string_literal
- We may now return frozen strings, now that we are using frozen_string_literal.
  This could affect methods like `Converter#convert`. Even if some method seems
  to return a thawed string in some situations, users should simiply assume all
  strings are frozen.

### Added

- MinitestToRspec.gem_version
- [#7](https://github.com/jaredbeck/minitest_to_rspec/pull/7) - Support for
  converting methods named test_*

### Fixed

- None

## 0.9.0 (2017-10-24)

### Breaking Changes

- Drop support for ruby < 2.2

### Added

None

### Fixed

- [#4](https://github.com/jaredbeck/minitest_to_rspec/issues/4) - Constrain
  dependency: sexp_processor < 4.8

## 0.8.0

### Changed

- No longer care about code style of output. See discussion in readme.
- Drop support for ruby 2.0

### Added

- Update ruby_parser to 3.8 (was 3.7)
- Use the official ruby2ruby instead of my sketchy sexp2ruby fork

### Fixed

None

## 0.7.1

### Changed

None

### Added

None

### Fixed

- Update sexp2ruby to 0.0.4 (was 0.0.3)

## 0.7.0

### Changed
- `assert` on a question-mark method converts to `eq(true)` instead
  of `be_truthy`. Likewise, `refute` converts to `eq(false)`. This is not
  guaranteed to be the same as minitest's fuzzy `assert`, but the convention of
  question-mark methods returning real booleans is strong.

### Added
- Converts assert_not_nil
- CLI
  - Added `--mocha` flag. If present, converts mocha to
    rspec-mocks. (Experimental)
  - Creates `target_file` directory if it does not exist
- Experimental
  - mocha: with

### Fixed
- `__FILE__` keyword in input

## 0.6.2

### Fixed
- Make runtime dependency on trollop explicit: declare in gemspec
- Improve output: Fewer unnecessary parentheses: to, to_not

## 0.6.1

### Fixed
- Improve output: Fewer unnecessary parentheses

## 0.6.0

### Added
- Converts
  - Draper::TestCase
  - ActionMailer::TestCase
- Experimental
  - mocha: once, twice
- Switch from ruby2ruby to sexp2ruby
  - Will have better output, e.g. ruby 1.9.3 hash syntax
  - Upgrade to ruby_parser 3.7

## 0.5.0

### Changed
- Executable
  - Renamed from `minitest_to_rspec` to `mt2rspec`
  - The `target_file` argument is now optional

## 0.4.0

### Added
- Experimental
  - Conversion of mocha to rspec-mocks
    - expects
    - any_instance

### Fixed
- NoMethodError when input contains stabby lambda

## 0.3.0

### Added
- Converts
  - `setup` and `teardown` to `before` and `after`
  - `assert_raise`, `assert_raises`
- CLI option: `--rails`
  - Prints `rails_helper` instead of `spec_helper`
  - Adds `:type` metadata, eg. `:type => :controller`
    - So far, only supports `:model` and `:controller`
- Experimental
  - Limited conversion of mocha to rspec-mocks
    - returns
    - stub
    - stub_everything
    - stubs
  - Ruby 1.9 hash syntax (See [ruby2ruby PR 37][3])

### Fixed
- Improved error message for class definition using module shorthand

## 0.2.1

### Fixed
- Declare ruby2ruby as a runtime dependency

## 0.2.0

### Added
- CLI.  Usage: `minitest_to_rspec source_file target_file`

## 0.1.0

Initial release.  11 assertions are supported.

[1]: http://semver.org/spec/v2.0.0.html
[2]: http://keepachangelog.com/
[3]: https://github.com/seattlerb/ruby2ruby/pull/37
