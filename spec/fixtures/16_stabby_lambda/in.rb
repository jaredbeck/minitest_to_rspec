test "doing something should not change Banana count" do
  λ = -> { Banana.count }
  before = λ.call
  do_something
  after = λ.call
  assert_equal before, after
end
