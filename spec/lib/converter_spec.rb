require "spec_helper"

module MinitestToRspec
  RSpec.describe Converter do

    # Fixtures that represent rails use cases.  These will
    # instantiate Converter with `rails: true`.
    RAILS_FIXTURES = [15, 20]

    # The path to `spec/fixtures`
    SPEC_FIXTURES = File.join(__dir__, '..', 'fixtures')

    # Directories under `spec/fixtures`
    FIXTURE_DIRS = Dir.glob("#{SPEC_FIXTURES}/*")

    def convert(input, options = nil)
      options ||= { rails: false }
      described_class.new(options).convert(input)
    end

    def fixture_number(fixture)
      File.basename(fixture).split('_').first.to_i
    end

    def rails?(fixture)
      RAILS_FIXTURES.include?(fixture_number(fixture))
    end

    def read_input(fixture)
      File.read(File.join(fixture, "in.rb"))
    end

    def read_output(fixture)
      File.read(File.join(fixture, "out.rb"))
    end

    describe "#convert" do

      # To run just one of the following programmatically
      # generated examples, use RSpec's `--example` flag, e.g.
      # `rspec --example "17" spec/lib/converter_spec.rb`
      FIXTURE_DIRS.each do |fixture|
        it "converts: #{fixture}" do
          expected = read_output(fixture).strip
          options = { rails: rails?(fixture) }
          calculated = convert(read_input(fixture), options).strip
          expect(calculated).to eq(expected)
        end
      end

      it "supports rails option" do
        expect(
          convert("require 'test_helper'", rails: true)
        ).to eq('require("rails_helper")')
      end
    end
  end
end
