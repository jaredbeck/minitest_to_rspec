describe("#peel") do
  it("does not change flavor") do
    banana = Banana.new
    expect { banana.peel }.to_not(change { banana.flavor })
  end
end
