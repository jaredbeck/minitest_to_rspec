module MinitestToRspec
  module Exp
    module Calls

      # Represents a call to `returns`, the stubbing method
      # from `mocha`.
      class Returns < Call
        def initialize(exp)
          @exp = exp
        end

        # The message recipient
        def msg_recipient
          stubs_call.receiver
        end

        def known_variant?
          receiver_is_call_to_stubs? &&
            !values.empty? &&
            message.sexp_type == :lit
        end

        def message
          stubs_call.arguments[0]
        end

        # The return values
        def values
          arguments
        end

        private

        def receiver_is_call_to_stubs?
          r = receiver
          !r.nil? &&
            r.sexp_type == :call &&
            Call.new(r).method_name == :stubs
        end

        def stubs_call
          Call.new(receiver)
        end
      end
    end
  end
end
