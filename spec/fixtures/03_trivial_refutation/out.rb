require("spec_helper")
RSpec.describe(Kiwi) do
  it("is not delicious") do
    expect(Kiwi).to(be_falsey)
    expect(Kiwi.new.delicious?).to(eq(false))
  end
end
