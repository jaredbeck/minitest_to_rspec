RSpec.describe Kiwi do
  it "is not delicious" do
    expect(Kiwi.new.delicious?).to eq(false)
  end
end
