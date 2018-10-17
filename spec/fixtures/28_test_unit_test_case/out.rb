require("spec_helper")
RSpec.describe(Banana) do
  it("delicious") { expect(Banana.new.delicious?).to(eq(true)) }
end
