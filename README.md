# MinitestToRspec

Converts minitest files to rspec.

[![Build Status][1]][2] [![Code Climate][3]][4]

Example
-------

Input:

```ruby
require 'test_helper'
class BananaTest < ActiveSupport::TestCase
  test "is delicious" do
    assert Banana.new.delicious?
  end
end
```

Output:

```ruby
require("spec_helper")
RSpec.describe(Banana) do
  it("is delicious") { expect(Banana.new.delicious?).to(be_truthy) }
end
```

The code style is whatever [ruby2ruby][6] feels like printing,
and is not configurable.  The goal is not style, but to get to
rspec quickly.

Usage
-----

No CLI executable is provided yet, but ruby usage is simple.

```ruby
require 'minitest_to_rspec'
MinitestToRspec::Converter.new.convert("assert('banana')")
#=> "expect(\"banana\").to(be_truthy)"
```

Supported Assertions
--------------------

The first release will support:

Assertion              | Tested
---------------------- | ------
assert                 | ✔
assert_difference      |
assert_equal           | ✔
assert_match           |
assert_nil             |
assert_no_difference   |
assert_nothing_raised  |
assert_raises          |
refute                 | ✔
refute_equal           | ✔

See [doc/supported_assertions.md][5] for details.

[1]: https://travis-ci.org/jaredbeck/minitest_to_rspec.svg
[2]: https://travis-ci.org/jaredbeck/minitest_to_rspec
[3]: https://codeclimate.com/github/jaredbeck/minitest_to_rspec/badges/gpa.svg
[4]: https://codeclimate.com/github/jaredbeck/minitest_to_rspec
[5]: https://github.com/jaredbeck/minitest_to_rspec/blob/master/doc/supported_assertions.md
[6]: https://github.com/seattlerb/ruby2ruby
