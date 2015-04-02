class KiwiTest < ActiveSupport::TestCase
  test "is not delicious" do
    refute_equal true, Kiwi.new.delicious?
  end
end
