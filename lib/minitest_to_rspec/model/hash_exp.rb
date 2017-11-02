# frozen_string_literal: true

module MinitestToRspec
  module Model
    # Data object.  Represents a `:hash` S-expression.
    class HashExp < Base
      def initialize(sexp)
        assert_sexp_type(:hash, sexp)
        @exp = sexp.dup
      end

      # A slightly nicer implementation would be:
      # `@exp[1..-1].each_slice(2).to_h`
      # but that would require ruby >= 2.1
      def to_h
        Hash[@exp[1..-1].each_slice(2).to_a]
      end
    end
  end
end
