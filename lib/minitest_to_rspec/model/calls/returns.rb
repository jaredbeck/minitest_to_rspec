# frozen_string_literal: true

require_relative '../call'
require_relative '../../errors'

module MinitestToRspec
  module Model
    module Calls
      # Represents a call to `returns`, the stubbing method
      # from `mocha`.
      class Returns < Call
        KNOWN_RECEIVERS = %i[stubs expects with].freeze

        def initialize(exp)
          @exp = exp
          raise UnknownVariant unless known_variant?
        end

        def stub?
          receiver_chain_include?(:stubs)
        end

        def any_instance?
          receiver_chain_include?(:any_instance)
        end

        def expectation?
          receiver_chain_include?(:expects)
        end

        def known_variant?
          r = receiver
          !r.nil? &&
            r.sexp_type == :call &&
            KNOWN_RECEIVERS.include?(Call.new(r).method_name) &&
            !values.empty? &&
            message.sexp_type == :lit
        end

        def message
          calls_in_receiver_chain
            .find { |c| [:stubs, :expects].include? c.method_name }
            .arguments[0]
        end

        # To avoid a `ProcessingError` please check `known_variant?`
        # before calling `rspec_mocks_method`.
        def rspec_mocks_method
          s = stub?
          e = expectation?
          if s && e
            raise ProcessingError, 'Method chain contains stubs and expects'
          elsif s
            :allow
          elsif e
            :expect
          else
            raise ProcessingError, 'Found returns without stubs or expects'
          end
        end

        # Returns `Sexp` representing the object that will receive
        # the stubbed message.  Examples:
        #
        #     banana.stubs(:delicious?).returns(true)
        #     Kiwi.any_instance.stubs(:delicious?).returns(false)
        #
        # On the first line, the `rspec_msg_recipient` is `banana`. On the
        # second, `Kiwi`.
        #
        def rspec_msg_recipient
          receiver_chain.compact.last
        end

        # The return values
        def values
          arguments
        end

        def with
          w = calls_in_receiver_chain.find { |c| c.method_name == :with }
          w.nil? ? [] : w.arguments
        end
      end
    end
  end
end
