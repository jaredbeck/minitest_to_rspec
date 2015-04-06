require "spec_helper"

module MinitestToRspec
  RSpec.describe Converter do

    SPEC_FIXTURES = File.join(__dir__, '..', 'fixtures')
    FIXTURE_DIRS = Dir.glob("#{SPEC_FIXTURES}/*")

    def convert(input, options = nil)
      options ||= { rails_helper: false }
      described_class.new(options).convert(input)
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

      it "supports rails_helper option" do
        expect(
          convert("require 'test_helper'", rails_helper: true)
        ).to eq('require("rails_helper")')
      end
    end
  end
end
