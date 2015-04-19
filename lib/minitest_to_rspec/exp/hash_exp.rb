module MinitestToRspec
  module Exp

    # Data object.  Represents a `:hash` S-expression.
    class HashExp < Base
      def initialize(sexp)
        assert_sexp_type(:hash, sexp)
        @exp = sexp.dup
      end

      def to_h
        @exp[1..-1].each_slice(2).to_h
      end
    end
  end
end
