module MinitestToRspec
  RSpec.describe ModuleShorthandError do
    describe "#message" do
      it "explains that class definition is unsupported" do
        expect(described_class.new.to_s).to include(
          "Module shorthand (A::B::C) is not supported"
        )
      end
    end
  end
end
