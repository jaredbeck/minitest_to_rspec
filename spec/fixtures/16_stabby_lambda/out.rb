it "doing something should not change Banana count" do
  λ = lambda { Banana.count }
  before = λ.call
  do_something
  after = λ.call
  expect(after).to(eq(before))
end
