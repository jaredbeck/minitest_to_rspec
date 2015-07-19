require_relative "../call"
require_relative "../../errors"

module MinitestToRspec
  module Model
    module Calls

      # Represents a call to `returns`, the stubbing method
      # from `mocha`.
      class Returns < Call
        KNOWN_RECEIVERS = %i[stubs expects]
        RSPEC_MOCK_METHODS = { expects: :expect, stubs: :allow }

        def initialize(exp)
          @exp = exp
          raise UnknownVariant unless known_variant?
        end

        def any_instance?
          rcr = receiver_call.receiver
          if !rcr.nil? && sexp_type?(:call, rcr)
            Call.new(rcr).method_name == :any_instance
          else
            false
          end
        end

        # The message recipient
        def msg_recipient
          receiver_call.receiver
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
          receiver_call.arguments[0]
        end

        # To avoid a `ProcessingError` please check `known_variant?`
        # before calling `rspec_mocks_method`.
        def rspec_mocks_method
          RSPEC_MOCK_METHODS[receiver_call.method_name]
        end

        # Returns `Sexp` representing the object that will receive
        # the stubbed message.  Examples:
        #
        #     banana.stubs(:delicious?).returns(true)
        #     Kiwi.any_instance.stubs(:delicious?).returns(false)
        #
        # The `rspec_msg_recipient` is `banana` and `Kiwi`, respectively.
        #
        def rspec_msg_recipient
          any_instance? ? Call.new(msg_recipient).receiver : msg_recipient
        end

        # The return values
        def values
          arguments
        end
      end
    end
  end
end
