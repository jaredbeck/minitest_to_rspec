require("spec_helper")
RSpec.describe(Kiwi) do
  it("is not delicious") { expect(Kiwi.new.delicious?).to(be_falsey) }
end
