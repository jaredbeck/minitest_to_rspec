describe "#peel" do
  test "does not change flavor" do
    banana = Banana.new
    assert_no_difference "banana.flavor" do
      banana.peel
    end
  end
end
