RSpec.describe Kiwi do
  it "is not delicious" do
    expect(Kiwi.new.delicious?).to_not eq(true)
  end
end
