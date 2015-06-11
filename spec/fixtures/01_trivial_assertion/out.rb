require "spec_helper"
RSpec.describe Banana do
  it "is delicious" { expect(Banana.new.delicious?).to be_truthy }
end
