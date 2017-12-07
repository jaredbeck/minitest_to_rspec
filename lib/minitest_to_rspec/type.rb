# frozen_string_literal: true

module MinitestToRspec
  # Runtime type assertions.
  module Type
    class << self
      def assert(types, value)
        unless array_wrap(types).any? { |t| value.is_a?(t) }
          raise TypeError, "Expected #{types}, got #{value}"
        end
      end

      def bool(value)
        unless [false, true].include?(value)
          raise TypeError, "Expected Boolean, got #{value}"
        end
      end

      private

      # Implementation copied from Array.wrap in ActiveSupport 5
      def array_wrap(object)
        if object.nil?
          []
        elsif object.respond_to?(:to_ary)
          object.to_ary || [object]
        else
          [object]
        end
      end
    end
  end
end
