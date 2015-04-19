require_relative "base"

module MinitestToRspec
  module Exp

    # Data object.  Represents a `:class` S-expression.
    class Klass < Base
      def initialize(exp)
        assert_sexp_type(:class, exp)
        @exp = exp.dup
        assert_valid_name
      end

      # Raise an error if we don't know now to process the name
      # of this class.  Specifically, classes with module-shorthand.
      def assert_valid_name
        if name.is_a?(Symbol)
          # Valid
        elsif name.respond_to?(:sexp_type) && name.sexp_type == :colon2
          raise ModuleShorthandError
        else
          raise ProcessingError, "Unexpected class expression: #{name}"
        end
      end

      def block
        @exp[3..-1] || []
      end

      # Returns the name of the class.  Examples:
      #
      # - Banana #=> :Banana
      # - Fruit::Banana #=> s(:colon2, s(:const, :Fruit), :Banana)
      #
      # Note that the latter (module shorthand) is not supported
      # by MinitestToRspec.  See `#assert_valid_name`.
      #
      def name
        @exp[1]
      end

      # Returns the "inheritance".  Examples:
      #
      # - Inherit nothing #=> nil
      # - Inherit Foo #=> s(:const, :Foo)
      # - Inherit Bar::Foo #=> s(:colon2, s(:const, :Bar), :Foo)
      #
      def parent
        @exp[2]
      end
    end
  end
end
