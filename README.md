# MinitestToRspec

Converts [minitest][8] files to [rspec][9].

[![Build Status][1]][2] [![Code Climate][3]][4] [![Test Coverage][7]][4]

Selected assertions from [Test::Unit][26], [minitest][8], and
[ActiveSupport][27] are converted to [rspec-expectations][25].
Selected methods from [mocha][28] are converted to [rspec-mocks][24].

Example
-------

Input:

```ruby
require 'test_helper'
class ArrayTest < ActiveSupport::TestCase
  test "changes length" do
    ary = []
    assert_difference "ary.length" do
      ary.push(:x)
    end
  end
end
```

Output:

```ruby
require("spec_helper")
RSpec.describe(Array) do
  it("changes length") do
    ary = []
    expect { ary.push(:x) }.to(change { ary.length })
  end
end
```

The code style is whatever [ruby2ruby][6] feels like printing,
and is not configurable.  Comments are discarded.

Usage
-----

### CLI

```bash
gem install minitest_to_rspec
bundle exec minitest_to_rspec --rails source_file target_file
```

### Ruby

```ruby
require 'minitest_to_rspec'
MinitestToRspec::Converter.new.convert("assert('banana')")
#=> "expect(\"banana\").to(be_truthy)"
```

Supported Assertions
--------------------

Selected assertions from minitest, Test::Unit, and ActiveSupport.
See [doc/supported_assertions.md][5] for rationale.  Contributions
are welcome.

Assertion                   | Arity | Source
--------------------------- | ----- | ------
assert                      |       |
assert_difference           | 1,2   |
[assert_equal][23]          | 2,3   | Test::Unit
[assert_not_equal][22]      | 2,3   | Test::Unit
assert_match                |       |
assert_nil                  |       |
[assert_no_difference][12]  |       | ActiveSupport
[assert_nothing_raised][10] |       | Test::Unit
[assert_raise][11]          | 0..2  | Test::Unit
[assert_raises][13]         | 0..2  | Minitest
refute                      |       |
refute_equal                |       |

Supported Mocha
---------------

Mocha                 | Arity | Block | Notes
--------------------- | ----- | ----- | -------
[expects][21]         | 1     | n/a   |
[stub][19]            | 0,1,2 | no    |
[stub_everything][18] | 0,1,2 | no    | Uses `as_null_object`, not the same.
[stubs][20]           | 1     | n/a   |

Notably not yet supported: `any_instance`

Acknowledgements
----------------

Uses [ruby_parser][14], [sexp_processor][15], and [ruby2ruby][16]
by [Ryan Davis][17].

[1]: https://travis-ci.org/jaredbeck/minitest_to_rspec.svg
[2]: https://travis-ci.org/jaredbeck/minitest_to_rspec
[3]: https://codeclimate.com/github/jaredbeck/minitest_to_rspec/badges/gpa.svg
[4]: https://codeclimate.com/github/jaredbeck/minitest_to_rspec
[5]: https://github.com/jaredbeck/minitest_to_rspec/blob/master/doc/supported_assertions.md
[6]: https://github.com/seattlerb/ruby2ruby
[7]: https://codeclimate.com/github/jaredbeck/minitest_to_rspec/badges/coverage.svg
[8]: https://github.com/jaredbeck/minitest_to_rspec/blob/master/doc/minitest.md
[9]: https://github.com/jaredbeck/minitest_to_rspec/blob/master/doc/rspec.md
[10]: http://www.rubydoc.info/gems/test-unit/3.0.9/Test/Unit/Assertions#assert_nothing_raised-instance_method
[11]: http://ruby-doc.org/stdlib-2.1.0/libdoc/test/unit/rdoc/Test/Unit/Assertions.html#method-i-assert_raise
[12]: http://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference
[13]: http://www.rubydoc.info/gems/minitest/5.5.1/Minitest/Assertions#assert_raises-instance_method
[14]: https://github.com/seattlerb/ruby_parser
[15]: https://github.com/seattlerb/sexp_processor
[16]: https://github.com/seattlerb/ruby2ruby
[17]: https://github.com/zenspider
[18]: http://www.rubydoc.info/github/floehopper/mocha/Mocha/API:stub_everything
[19]: http://www.rubydoc.info/github/floehopper/mocha/Mocha/API#stub-instance_method
[20]: http://www.rubydoc.info/github/floehopper/mocha/Mocha/ObjectMethods#stubs-instance_method
[21]: http://www.rubydoc.info/github/floehopper/mocha/Mocha/ObjectMethods:expects
[22]: http://www.rubydoc.info/gems/test-unit/3.0.9/Test/Unit/Assertions#assert_not_equal-instance_method
[23]: http://www.rubydoc.info/gems/test-unit/3.0.9/Test/Unit/Assertions#assert_equal-instance_method
[24]: https://github.com/rspec/rspec-mocks
[25]: https://github.com/rspec/rspec-expectations
[26]: http://test-unit.github.io/
[27]: https://rubygems.org/gems/activesupport
[28]: http://gofreerange.com/mocha/docs/
