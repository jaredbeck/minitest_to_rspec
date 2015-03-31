require 'test_helper'

class KiwiTest < ActiveSupport::TestCase
  test "is not delicious" do
    refute Kiwi.new.delicious?
  end
end
