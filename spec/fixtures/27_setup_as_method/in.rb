require 'test_helper'

class BananaTest < ActiveSupport::TestCase
  include Monkeys

  def setup
    fend_off_the_monkeys
  end

  test "is delicious" do
    assert Banana.new.delicious?
  end

  def teardown
    appologize_to_the_monkeys
  end
end
