require "spec_helper"

module MinitestToRspec
  RSpec.describe Converter do

    SPEC_FIXTURES = File.join(__dir__, '..', 'fixtures')
    FIXTURE_DIRS = Dir.glob("#{SPEC_FIXTURES}/*")

    def convert(input, options = nil)
      options ||= { rails_helper: false }
      described_class.new(options).convert(input)
    end

    def read_input(fixture)
      File.read(File.join(fixture, "in.rb"))
    end

    def read_output(fixture)
      File.read(File.join(fixture, "out.rb"))
    end

    describe "#convert" do
      FIXTURE_DIRS.each do |fixture|
        it "converts: #{fixture}" do
          expected = read_output(fixture).strip
          calculated = convert(read_input(fixture)).strip
          expect(calculated).to eq(expected)
        end
      end

      it "supports rails_helper option" do
        expect(
          convert("require 'test_helper'", rails_helper: true)
        ).to eq('require("rails_helper")')
      end
    end
  end
end
