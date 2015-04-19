require_relative "../call"
require_relative "../../errors"

module MinitestToRspec
  module Exp
    module Calls

      # Represents a call to `returns`, the stubbing method
      # from `mocha`.
      class Returns < Call
        KNOWN_RECEIVERS = %i[stubs expects]

        def initialize(exp)
          @exp = exp
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
          case receiver_call.method_name
          when :expects
            :expect
          when :stubs
            :allow
          else
            raise ProcessingError, "Unknown variant of returns"
          end
        end

        # The return values
        def values
          arguments
        end

        private

        # The receiver of the `:returns` message is a `:call`
        # either to `#stubs` or `#expects`.
        def receiver_call
          Call.new(receiver)
        end
      end
    end
  end
end
