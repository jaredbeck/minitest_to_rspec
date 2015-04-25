require_relative "../exp/call"
require_relative "../exp/calls/returns"
require_relative "../exp/hash_exp"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Call < Base
      def initialize(sexp, rails)
        @exp = Exp::Call.new(sexp)
        sexp.clear
        @rails = rails
      end

      # Given a `Exp::Call`, returns a `Sexp`
      def process
        if respond_to?(name_of_processing_method, true)
          send(name_of_processing_method)
        else
          @exp.original
        end
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

      def expect_receive_and_return(msg_recipient, msg, return_values)
        expect_to(receive_and_return(msg, return_values), msg_recipient, true)
      end

      # Given a `Sexp` representing a `Hash` of message expectations,
      # return an array of `Sexp`, each representing an expectation
      # in rspec-mocks syntax.
      def hash_to_expectations(sexp, receiver)
        Exp::HashExp.new(sexp).to_h.map { |msg, ret_val|
          expect_receive_and_return(
            receiver.deep_clone, msg, wrap_sexp(ret_val)
          )
        }
      end

      def match(pattern)
        matcher(:match, pattern)
      end

      def method_assert
        expect_to(be_truthy, @exp.arguments[0], true)
      end

      def method_assert_equal
        expected = @exp.arguments[0]
        calculated = @exp.arguments[1]
        expect_to(eq(expected), calculated, true)
      end

      def method_assert_match
        pattern = @exp.arguments[0]
        string = @exp.arguments[1]
        expect_to(match(pattern), string, true)
      end

      def method_assert_nil
        expect_to(be_nil, @exp.arguments[0], true)
      end

      def method_assert_not_equal
        expected = @exp.arguments[0]
        calculated = @exp.arguments[1]
        expect_to_not(eq(expected), calculated, true)
      end

      def method_expects
        if @exp.num_arguments == 1
          mocha_expects
        else
          @exp.original
        end
      end

      def method_refute
        expect_to(be_falsey, @exp.arguments[0], true)
      end

      def method_refute_equal
        unexpected = @exp.arguments[0]
        calculated = @exp.arguments[1]
        expect_to_not(eq(unexpected), calculated, true)
      end

      def method_returns
        r = Exp::Calls::Returns.new(@exp.original)
        if r.known_variant?
          m = "#{r.rspec_mocks_method}_receive_and_return"
          send(m, r.msg_recipient, r.message, r.values)
        else
          @exp.original
        end
      end

      def method_require
        if @exp.require_test_helper?
          require_spec_helper
        else
          @exp.original
        end
      end

      # Happily, the no-block signatures of [stub][3] are the
      # same as [double][2].
      #
      # - (name)
      # - (stubs)
      # - (name, stubs)

      def method_stub
        if @exp.receiver.nil?
          s(:call, nil, :double, *@exp.arguments)
        else
          @exp.original
        end
      end

      # [stub_everything][1] responds to all messages with nil.
      # [double.as_null_object][4] responds with self.  Not a
      # drop-in replacement, but will work in many situations.
      # RSpec doesn't provide an equivalent to `stub_everything`,
      # AFAIK.

      def method_stub_everything
        if @exp.receiver.nil?
          d = s(:call, nil, :double, *@exp.arguments)
          s(:call, d, :as_null_object, )
        else
          @exp.original
        end
      end

      def method_test
        s(:call, nil, :it, *@exp.arguments)
      end

      def mocha_expects
        arg = @exp.arguments.first
        if sexp_type?(:hash, arg)
          mocha_expects_hash(arg)
        elsif sexp_type?(:lit, arg)
          mocha_expects_lit(arg)
        else
          @exp.original
        end
      end

      def mocha_expects_hash(hash_sexp)
        assert_sexp_type(:hash, hash_sexp)
        pointless_lambda(hash_to_expectations(hash_sexp, @exp.receiver))
      end

      def mocha_expects_lit(lit_sexp)
        assert_sexp_type(:lit, lit_sexp)
        expect_to(receive_and_call_original(lit_sexp), @exp.receiver, true)
      end

      def name_of_processing_method
        "method_#{@exp.method_name}".to_sym
      end

      # Given `array_of_calls`, returns a `Sexp` representing a
      # self-executing lambda.
      #
      # This works around the fact that `sexp_processor` expects us to return
      # a single `Sexp`, not an array of `Sexp`.  We also can't return a
      # `:block`, or else certain input would produce nested blocks (e.g.
      # `s(:block, s(:block, ..))`) which `ruby2ruby` (naturally) does not know
      # how to process.  So, the easiest solution I could think of is a
      # self-executing lambda.
      #
      # Currently, the only `:call` which we process into multiple calls is
      # the hash form of a mocha `#expects`, thankfully uncommon.
      #
      # To get better output (without a pointless lambda) we would have to
      # process `:block` *and* `:defn`, which we are not yet doing.

      def pointless_lambda(array_of_calls)
        assert_sexp_type_array(:call, array_of_calls)
        s(:call,
          s(:iter,
            s(:call, nil, :lambda),
            s(:args),
            s(:block,
              s(:str, "Sorry for the pointless lambda here."),
              *array_of_calls
            )
          ),
          :call
        )
      end

      def receive(message)
        s(:call, nil, :receive, message)
      end

      def receive_and_call_original(message)
        s(:call, s(:call, nil, :receive, message), :and_call_original)
      end

      def receive_and_return(message, return_values)
        s(:call, receive(message), :and_return, *return_values)
      end

      def require_spec_helper
        prefix = @rails ? "rails" : "spec"
        s(:call, nil, :require, s(:str, "#{prefix}_helper"))
      end

      # Wraps `obj` in an `Array` if it is a `Sexp`
      def wrap_sexp(obj)
        obj.is_a?(Sexp) ? [obj] : obj
      end
    end
  end
end

# [1]: http://bit.ly/1yll6ND
# [2]: http://bit.ly/1CRdmP3
# [3]: http://bit.ly/1aY2mJN
# [4]: http://bit.ly/1OtwDOY
