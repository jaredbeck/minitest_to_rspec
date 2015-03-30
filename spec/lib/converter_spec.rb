require "spec_helper"

module MinitestToRspec
  RSpec.describe Converter do

    def convert(input)
      described_class.new.convert(input)
    end

    def input(fixture)
      File.read(fixture_path(fixture, "in.rb"))
    end

    def fixture_path(fixture, file)
      File.join(__dir__, '..', 'fixtures', fixture, file)
    end

    def output(fixture)
      File.read(fixture_path(fixture, "out.rb"))
    end

    describe "#convert" do
      it "converts a trivial assertion" do
        fixture = "01_trivial_assertion"
        expect(convert(input(fixture))).to eq(output(fixture))
      end

      it "converts empty TestCase" do
        fixture = "02_empty_testcase"
        expect(convert(input(fixture))).to eq(output(fixture))
      end
    end
  end
end
