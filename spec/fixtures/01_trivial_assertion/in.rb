require 'test_helper'

class BananaTest < ActiveSupport::TestCase
  test "is delicious" do
    assert Banana
    assert Banana.new.delicious?
  end
end
