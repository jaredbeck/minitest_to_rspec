RSpec.describe(Kiwi) do
  it("is not delicious") { expect(Kiwi.new.delicious?).to(eq(false)) }
end
