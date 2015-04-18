require_relative "../exp/call"
require_relative "../exp/calls/returns"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Call < Base
      class << self
        def process(sexp, rails)
          exp = Exp::Call.new(sexp)
          sexp.clear
          process_exp(exp, rails)
        end

        private

        def allow_receive_and_return(msg_recipient, msg, return_values)
          allow_to(msg_recipient, receive_and_return(msg, return_values))
        end

        def be_falsey
          matcher(:be_falsey)
        end

        def be_nil
          matcher(:be_nil)
        end

        def be_truthy
          matcher(:be_truthy)
        end

        def eq(exp)
          matcher(:eq, exp)
        end

        def match(pattern)
          matcher(:match, pattern)
        end

        def method_assert(exp)
          expect_to(be_truthy, exp.arguments[0], true)
        end

        def method_assert_equal(exp)
          expected = exp.arguments[0]
          calculated = exp.arguments[1]
          expect_to(eq(expected), calculated, true)
        end

        def method_assert_match(exp)
          pattern = exp.arguments[0]
          string = exp.arguments[1]
          expect_to(match(pattern), string, true)
        end

        def method_assert_nil(exp)
          expect_to(be_nil, exp.arguments[0], true)
        end

        def method_refute(exp)
          expect_to(be_falsey, exp.arguments[0], true)
        end

        def method_refute_equal(exp)
          unexpected = exp.arguments[0]
          calculated = exp.arguments[1]
          expect_to_not(eq(unexpected), calculated, true)
        end

        def method_returns(exp)
          r = Exp::Calls::Returns.new(exp.original)
          if r.known_variant?
            allow_receive_and_return(r.msg_recipient, r.message, r.values)
          else
            exp.original
          end
        end

        # Happily, the no-block signatures of [stub][3] are the
        # same as [double][2].
        #
        # - (name)
        # - (stubs)
        # - (name, stubs)

        def method_stub(exp)
          if exp.receiver.nil?
            s(:call, nil, :double, *exp.arguments)
          else
            exp.original
          end
        end

        # [stub_everything][1] responds to all messages with nil.
        # [double.as_null_object][4] responds with self.  Not a
        # drop-in replacement, but will work in many situations.
        # RSpec doesn't provide an equivalent to `stub_everything`,
        # AFAIK.

        def method_stub_everything(exp)
          if exp.receiver.nil?
            d = s(:call, nil, :double, *exp.arguments)
            s(:call, d, :as_null_object, )
          else
            exp.original
          end
        end

        def method_test(exp)
          s(:call, nil, :it, *exp.arguments)
        end

        def name_of_processing_method(exp)
          "method_#{exp.method_name}".to_sym
        end

        def processable?(exp)
          respond_to?(name_of_processing_method(exp), true)
        end

        # Given a `Exp::Call`, returns a `Sexp`
        def process_exp(exp, rails)
          if exp.require_test_helper?
            require_spec_helper(rails)
          elsif processable?(exp)
            send_to_processing_method(exp)
          else
            exp.original
          end
        end

        def receive(message)
          s(:call, nil, :receive, message)
        end

        def receive_and_return(message, return_values)
          s(:call, receive(message), :and_return, *return_values)
        end

        def require_spec_helper(rails)
          prefix = rails ? "rails" : "spec"
          s(:call, nil, :require, s(:str, "#{prefix}_helper"))
        end

        def send_to_processing_method(exp)
          send(name_of_processing_method(exp), exp)
        end
      end
    end
  end
end

# [1]: http://bit.ly/1yll6ND
# [2]: http://bit.ly/1CRdmP3
# [3]: http://bit.ly/1aY2mJN
# [4]: http://bit.ly/1OtwDOY
