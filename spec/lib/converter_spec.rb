# frozen_string_literal: true

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

    def convert(input, file_path, rails, mocha)
      described_class.new(rails: rails, mocha: mocha).convert(input, file_path)
    end

    def input_file_path(fixture)
      File.join(fixture, "in.rb")
    end

    def fixture_number(fixture)
      File.basename(fixture).split('_').first.to_i
    end

    def output_file_path(fixture)
      File.join(fixture, "out.rb")
    end

    def rails?(fixture)
      RAILS_FIXTURES.include?(fixture_number(fixture))
    end

    def read_input(fixture)
      File.read(input_file_path(fixture))
    end

    def read_output(fixture)
      File.read(output_file_path(fixture))
    end

    describe "#convert" do
      # To run just one of the following programmatically
      # generated examples, use RSpec's `--example` flag, e.g.
      # `rspec --example "17" spec/lib/converter_spec.rb`
      FIXTURE_DIRS.each do |fixture|
        it "converts: #{fixture}" do
          expected = read_output(fixture).strip
          input = read_input(fixture)
          path = input_file_path(fixture)
          calculated = convert(input, path, rails?(fixture), true).strip
          expect(calculated).to eq(expected)
        end
      end

      it "supports rails option" do
        expect(
          convert("require 'test_helper'", nil, true, false)
        ).to eq('require("rails_helper")')
      end

      context "__FILE__ keyword" do
        it "replaces with the given file path" do
          expect(
            convert("__FILE__", "/banana/kiwi/mango", false, false)
          ).to eq('"/banana/kiwi/mango"')
        end

        it "replaces with helpful message when not provided" do
          expect(
            convert("__FILE__", nil, false, false)
          ).to match(/No file path provided/)
        end
      end
    end
  end
end
