require("spec_helper")

RSpec.describe(Banana) do
  include(Monkeys)
  
  before { fend_off_the_monkeys }
  
  it("is very delicious") do
    Banana.deliciousness *= 100
    
    expect(Banana.new.delicious?).to(eq(true))
  end
  
  after { appologize_to_the_monkeys }
end
