require "spec_helper"

module MinitestToRspec
  RSpec.describe Converter do

    # This is what an end-to-end test might look like, but then
    # again these tests may end up being more isolated.
    it "converts minitest to rspec" do
      skip "Not yet implemented"
      input = <<-EOS
require 'test_helper'

class BananaTest < ActiveSupport::TestCase
  test "is delicious" do
    assert Banana.new.delicious?
  end
end
      EOS
      output = described_class.new.convert(input)
      expect(output).to eq(
        <<-EOS
require "spec_helper"

RSpec.describe Banana do
  it "is delicious" do
    expect(Banana.new.delicious?).to be_truthy
  end
end
        EOS
      )
    end
  end
end
