# frozen_string_literal: true

require 'minitest_to_rspec/type'
require 'minitest_to_rspec/input/model/call'

module MinitestToRspec
  module Minitest
    # Represents an `expects` or a `stubs` from mocha.
    # Conceptually the same as `Rspec::Stub`.
    class Stub
      def initialize(call)
        Type.assert(Input::Model::Call, call)
        @call = call
      end

      # Given e.g. `X.any_instance.expects(:y)`, returns `X`.
      def receiver
        chain = @call.receiver_chain
        last = chain[-1]
        last.nil? ? chain[-2] : last
      end

      # Returns true if we are stubbing any instance of `receiver`.
      def any_instance?
        @call.calls_in_receiver_chain.any? { |i|
          i.method_name.to_s.include?('any_instance')
        }
      end

      # Given e.g. `expects(:y)`, returns `:y`.
      def message
        case @call.method_name
        when :expects
          @call.arguments.first
        else
          the_call_to_stubs_or_expects.arguments.first
        end
      end

      def with
        @call.find_call_in_receiver_chain(:with)&.arguments&.first
      end

      def returns
        case @call.method_name
        when :returns
          @call.arguments.first
        else
          @call.find_call_in_receiver_chain(:returns)&.arguments&.first
        end
      end

      # TODO: add support for
      # - at_least
      # - at_least_once
      # - at_most
      # - at_most_once
      # - never
      def count
        case @call.method_name
        when :expects, :once
          1
        when :returns
          the_call_to_stubs_or_expects.method_name == :expects ? 1 : nil
        when :twice
          2
        end
      end

      private

      # Given an `exp` representing a chain of calls, like
      # `stubs(x).returns(y).once`, finds the call to `stubs` or `expects`.
      def the_call_to_stubs_or_expects
        @call.find_call_in_receiver_chain(%i[stubs expects])
      end
    end
  end
end
