RSpec.describe(Banana) do
  it("random stuff from mocha") do
    allow(Banana).to(receive(:delicious?).and_return(true))
  end
end
