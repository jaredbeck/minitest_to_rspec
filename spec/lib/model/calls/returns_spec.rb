# frozen_string_literal: true

require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Model
    module Calls
      RSpec.describe Returns do

        def parse(ruby)
          RubyParser.new.parse(ruby)
        end

        describe "#rspec_msg_recipient" do
          context "stub on an instance" do
            it "returns Sexp representing the instance" do
              input = parse("x.stubs(:y?).returns(:z)")
              expect(
                described_class.new(input).rspec_msg_recipient
              ).to eq(s(:call, nil, :x))
            end
          end

          context "stub on X.any_instance" do
            it "returns Sexp representing X" do
              input = parse("X.any_instance.stubs(:y?).returns(:z)")
              expect(
                described_class.new(input).rspec_msg_recipient
              ).to eq(s(:const, :X))
            end
          end
        end
      end
    end
  end
end
