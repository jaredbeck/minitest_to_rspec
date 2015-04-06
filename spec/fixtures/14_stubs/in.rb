class BananaTest < ActiveSupport::TestCase
  test "random stuff from mocha" do
    Banana.stubs(:delicious?).returns(true)
  end
end
