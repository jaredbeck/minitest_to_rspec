require 'test_helper'

class BananaTest < ActiveSupport::TestCase
  include Monkeys

  setup do
    fend_off_the_monkeys
  end

  test "is delicious" do
    assert Banana.new.delicious?
  end

  teardown do
    appologize_to_the_monkeys
  end
end
