Change Log
==========

This project follows [semver 2.0.0][1] and the recommendations
of [keepachangelog.com][2].

0.6.0 (Unreleased)
------------------

### Added
- Converts
  - Draper::TestCase

0.5.0
-----

### Changed
- Executable
  - Renamed from `minitest_to_rspec` to `mt2rspec`
  - The `target_file` argument is now optional

0.4.0
-----

### Added
- Experimental
  - Conversion of mocha to rspec-mocks
    - expects
    - any_instance

### Fixed
- NoMethodError when input contains stabby lambda

0.3.0
-----

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

0.2.1
-----

### Fixed
- Declare ruby2ruby as a runtime dependency

0.2.0
-----

### Added
- CLI.  Usage: `minitest_to_rspec source_file target_file`

0.1.0
-----

Initial release.  11 assertions are supported.

[1]: http://semver.org/spec/v2.0.0.html
[2]: http://keepachangelog.com/
[3]: https://github.com/seattlerb/ruby2ruby/pull/37
