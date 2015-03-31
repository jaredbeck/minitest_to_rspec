class KiwiTest < ActiveSupport::TestCase
  test "is not delicious" do
    assert_equal false, Kiwi.new.delicious?
  end
end
