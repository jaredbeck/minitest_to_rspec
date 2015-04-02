require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Iter do
      describe ".process" do

        def parse(ruby)
          RubyParser.new.parse(ruby)
        end

        def process(input)
          described_class.process(input)
        end

        it "replaces assert_difference with expect to change" do
          input = parse <<-EOS
            assert_difference "ary.length" do ary.push("banana") end
          EOS
          output = parse <<-EOS
            expect { ary.push("banana") }.to(change { ary.length })
          EOS
          expect(process(input)).to eq(output)
        end

        it "replaces assert_difference (arity 2) with expect to change by" do
          input = parse <<-EOS
            assert_difference "ary.length", +1 do
              ary.push("banana")
            end
          EOS
          output = parse <<-EOS
            expect { ary.push("banana") }.to(change { ary.length }.by(+1))
          EOS
          expect(process(input)).to eq(output)
        end

        it "replaces assert_no_difference with expect to_not change" do
          input = parse <<-EOS
            assert_no_difference "banana.flavor" do
              banana.peel
            end
          EOS
          output = parse <<-EOS
            expect { banana.peel }.to_not(change { banana.flavor })
          EOS
          expect(process(input)).to eq(output)
        end

        it "replaces assert_raises with expect to raise" do
          input = parse <<-EOS
            assert_raises(NotDeliciousError) { Kiwi.delicious! }
          EOS
          output = parse <<-EOS
            expect { Kiwi.delicious! }.to(raise_error(NotDeliciousError))
          EOS
          expect(process(input)).to eq(output)
        end

        it "replaces assert_nothing_raised with expect to_not raise" do
          input = parse <<-EOS
            assert_nothing_raised { Banana.delicious! }
          EOS
          output = parse <<-EOS
            expect { Banana.delicious! }.to_not(raise_error)
          EOS
          expect(process(input)).to eq(output)
        end

        context "sexp_type is not :iter" do
          it "raises ArgumentError" do
            expect {
              described_class.new(s(:str, "derp"))
            }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end
