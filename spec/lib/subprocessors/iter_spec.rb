require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Iter do
      describe ".new" do
        context "not an :iter" do
          it "raises error" do
            expect {
              described_class.new(s(:nil))
            }.to raise_error(TypeError)
          end
        end
      end

      describe "#process" do
        def parse(ruby)
          RubyParser.new.parse(ruby)
        end

        def process(input)
          described_class.new(input).process
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

        context "assert_raise" do
          it "replaces assert_raise with expect to raise" do
            input = parse <<-EOS
              assert_raise { Kiwi.delicious! }
            EOS
            output = parse <<-EOS
              expect { Kiwi.delicious! }.to raise_error
            EOS
            expect(process(input)).to eq(output)
          end

          it "replaces assert_raise(e) with expect to raise_error(e)" do
            input = parse <<-EOS
              assert_raise(NotDeliciousError) { Kiwi.delicious! }
            EOS
            output = parse <<-EOS
              expect { Kiwi.delicious! }.to raise_error(NotDeliciousError)
            EOS
            expect(process(input)).to eq(output)
          end

          it "replaces assert_raise(str) with raise_error, discards fail msg" do
            input = parse <<-EOS
              assert_raise("Fruit should not be hairy") { Kiwi.delicious! }
            EOS
            output = parse <<-EOS
              expect { Kiwi.delicious! }.to raise_error
            EOS
            expect(process(input)).to eq(output)
          end

          it "does not replace assert_raise(e1, e2)" do
            input = -> {
              parse("assert_raise(NotDelicious, NotYellow) { Kiwi.delicious! }")
            }
            expect(process(input.call)).to eq(input.call)
          end

          it "replaces assert_raise(e, str) with raise_error(e), discards fail msg" do
            input = parse <<-EOS
              assert_raise(NotDelicious, "Fruit should not be hairy") {
                Kiwi.delicious!
              }
            EOS
            output = parse <<-EOS
              expect { Kiwi.delicious! }.to raise_error(NotDelicious)
            EOS
            expect(process(input)).to eq(output)
          end
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

        it "replaces setup with before" do
          expect(
            process(parse('setup { peel_bananas }'))
          ).to eq(
            parse('before { peel_bananas }')
          )
        end

        it "replaces teardown with after" do
          expect(
            process(parse('teardown { compost_the_banana_peels }'))
          ).to eq(
            parse('after { compost_the_banana_peels }')
          )
        end
      end
    end
  end
end
