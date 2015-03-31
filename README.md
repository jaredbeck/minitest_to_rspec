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

Supported Assertions
--------------------

The first release will support:

- [x] assert
- [ ] assert_difference
- [x] assert_equal
- [ ] assert_match
- [ ] assert_nil
- [ ] assert_no_difference
- [ ] assert_nothing_raised
- [ ] assert_raises
- [x] refute
- [ ] refute_equal

See [doc/supported_assertions.md][5] for details.

[1]: https://travis-ci.org/jaredbeck/minitest_to_rspec.svg
[2]: https://travis-ci.org/jaredbeck/minitest_to_rspec
[3]: https://codeclimate.com/github/jaredbeck/minitest_to_rspec/badges/gpa.svg
[4]: https://codeclimate.com/github/jaredbeck/minitest_to_rspec
[5]: https://github.com/jaredbeck/minitest_to_rspec/blob/master/doc/supported_assertions.md
