test "changes length" do
  ary = []
  assert_difference "ary.length", +1 do
    ary.push("banana")
  end
end
