it("changes length") do
  ary = []
  expect { ary.push("banana") }.to(change { ary.length }.by(1))
end
