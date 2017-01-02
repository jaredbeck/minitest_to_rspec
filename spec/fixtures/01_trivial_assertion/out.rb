require("spec_helper")
RSpec.describe(Banana) do
  it("is delicious") do
    expect(Banana).to(be_truthy)
    expect(Banana.new.delicious?).to(eq(true))
  end
end
