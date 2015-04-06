Change Log
==========

This project follows [semver 2.0.0][1] and the recommendations
of [keepachangelog.com][2].

0.3.0 (Unreleased)
------------------

### Added
- Support for `setup` and `teardown`
- CLI option: `--rails` will `require("rails_helper")` instead
  of `"spec_helper"`

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
