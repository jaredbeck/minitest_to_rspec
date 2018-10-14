require 'test_helper'

class BananaTest < Test::Unit::TestCase
  def test_delicious
    assert Banana.new.delicious?
  end
end
