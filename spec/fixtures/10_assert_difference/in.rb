test "changes length" do
  ary = []
  assert_difference "ary.length" do
    ary.push("banana")
  end
end
