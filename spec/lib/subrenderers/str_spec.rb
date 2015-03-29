require "spec_helper"

module MinitestToRspec
  module Subrenderers
    RSpec.describe Str do
      describe "#process" do

        # Returns an S-expression representing a string.
        def str(value)
          s(:str, value)
        end

        it "can use double quotes" do
          out = StringIO.new
          described_class.process(str("banana"), out)
          expect(out.string).to eq('"banana"')
        end

        it "can use single quotes" do
          out = StringIO.new
          str_with_dbl = 'Jared says bananas are "delicious"'
          described_class.process(str(str_with_dbl), out)
          expect(out.string).to eq("'#{str_with_dbl}'")
        end

        it "can use percent-q" do
          out = StringIO.new
          str_with_both_q = %q(Jared's friend "agrees")
          described_class.process(str(str_with_both_q), out)
          expect(out.string).to eq("%q(#{str_with_both_q})")
        end
      end
    end
  end
end
