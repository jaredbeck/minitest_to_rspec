require "spec_helper"

module MinitestToRspec
  RSpec.describe Converter do

    SPEC_FIXTURES = File.join(__dir__, '..', 'fixtures')
    FIXTURE_DIRS = Dir.glob("#{SPEC_FIXTURES}/*")

    def convert(input)
      described_class.new.convert(input)
    end

    def input(fixture)
      File.read(File.join(fixture, "in.rb"))
    end

    def output(fixture)
      File.read(File.join(fixture, "out.rb"))
    end

    describe "#convert" do
      FIXTURE_DIRS.each do |fixture|
        it "converts: #{fixture}" do
          expected = output(fixture).strip
          calculated = convert(input(fixture)).strip
          expect(calculated).to eq(expected)
        end
      end
    end
  end
end
