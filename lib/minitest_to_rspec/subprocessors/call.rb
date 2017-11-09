# frozen_string_literal: true

require 'minitest_to_rspec/type'
require 'minitest_to_rspec/expression_builders/stub'
require_relative '../model/call'
require_relative '../model/hash_exp'
require_relative 'base'

module MinitestToRspec
  module Subprocessors
    # Processes `s(:call, ..)` expressions.
    class Call < Base
      # Mocha methods will only be processed if `--mocha` flag was given,
      # i.e. `mocha` argument in constructor is true.
      MOCHA_METHODS = %i[
        expects
        once
        returns
        stub
        stubs
        stub_everything
        twice
      ].freeze

      def initialize(sexp, rails, mocha)
        super(rails, mocha)
        @exp = Model::Call.new(sexp)
        sexp.clear
      end

      # Given a `Model::Call`, returns a `Sexp`
      def process
        if process?
          send(name_of_processing_method)
        else
          @exp.original
        end
      end

      def process?
        respond_to?(name_of_processing_method, true) &&
          (@mocha || !MOCHA_METHODS.include?(@exp.method_name))
      end

      private

      # - msg_rcp.  Message recipient.  The object to be stubbed.
      # - msg.  Message.  The name of the stubbed method.
      # - ret_vals.  Return values.
      # - any_ins.  Any instance?  True if this is an `any_instance` stub.
      # - with. Allowed arguments.
      def allow_receive_and_return(msg_rcp, msg, ret_vals, any_ins, with)
        allow_to(
          msg_rcp,
          receive_and_return(msg, ret_vals, with),
          any_ins
        )
      end

      # Given `exp`, an S-expression representing an rspec-mocks statement
      # (expect or allow) apply `ordinal`, which is either `:once` or `:twice`.
      # This feels like a hack.  No other processing "re-opens" an "output
      # sexp".
      def apply_expectation_count_to(exp, ordinal)
        exp[3] = s(:call, exp[3], ordinal)
        exp
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

      def call_to_question_mark?(exp)
        sexp_type?(:call, exp) && Model::Call.new(exp).question_mark_method?
      end

      def eq(exp)
        matcher(:eq, exp)
      end

      # - msg_rcp.  Message recipient.  The object to be stubbed.
      # - msg.  Message.  The name of the stubbed method.
      # - ret_vals.  Return values.
      # - any_ins.  Any instance?  True if this is an `any_instance` stub.
      # - with. Allowed arguments.
      def expect_receive_and_return(msg_rcp, msg, ret_vals, any_ins, with)
        expect_to(
          receive_and_return(msg, ret_vals, with),
          msg_rcp,
          true,
          any_ins
        )
      end

      # Given a `Sexp` representing a `Hash` of message expectations,
      # return an array of `Sexp`, each representing an expectation
      # in rspec-mocks syntax.
      def hash_to_expectations(sexp, receiver)
        Model::HashExp.new(sexp).to_h.map { |msg, ret_val|
          expect_receive_and_return(
            receiver.deep_clone, msg, wrap_sexp(ret_val), false, []
          )
        }
      end

      def match(pattern)
        matcher(:match, pattern)
      end

      def method_assert
        refsert eq(s(:true)), be_truthy
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

      def method_assert_not_nil
        expect_to_not(be_nil, @exp.arguments[0], true)
      end

      def method_assert_not_equal
        expected = @exp.arguments[0]
        calculated = @exp.arguments[1]
        expect_to_not(eq(expected), calculated, true)
      end

      def method_expects
        if @exp.num_arguments == 1
          mocha_expects(@exp)
        else
          @exp.original
        end
      end

      def method_once
        mocha_once(@exp)
      end

      def method_refute
        refsert eq(s(:false)), be_falsey
      end

      def method_refute_equal
        unexpected = @exp.arguments[0]
        calculated = @exp.arguments[1]
        expect_to_not(eq(unexpected), calculated, true)
      end

      # Processes an entire line of code that ends in `.returns`
      def method_returns
        receiver = mocha_stub_receiver(@exp)
        any_instance = rspec_any_instance?(@exp)
        message_call = mocha_stub_expects(@exp)
        message = message_call.arguments.first
        with = mocha_stub_with(@exp)
        returns = @exp.arguments.first
        count = message_call.method_name == :expects ? 1 : nil
        ExpressionBuilders::Stub.new(
          receiver, any_instance, message, with, returns, count
        ).to_rspec_exp
      rescue StandardError
        # TODO: We used to have an `UnknownVariant` error.
        # That was nice and specific.
        @exp.original
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
        mocha_stub(@exp)
      end

      # [stub_everything][1] responds to all messages with nil.
      # [double.as_null_object][4] responds with self.  Not a
      # drop-in replacement, but will work in many situations.
      # RSpec doesn't provide an equivalent to `stub_everything`,
      # AFAIK.

      def method_stub_everything
        if @exp.receiver.nil?
          d = s(:call, nil, :double, *@exp.arguments)
          s(:call, d, :as_null_object)
        else
          @exp.original
        end
      end

      def method_test
        s(:call, nil, :it, *@exp.arguments)
      end

      def method_twice
        mocha_twice(@exp)
      end

      def mocha_expects(exp)
        raise ArgumentError unless exp.is_a?(Model::Call)
        arg = exp.arguments.first
        if sexp_type?(:hash, arg)
          mocha_expects_hash(exp, arg)
        elsif sexp_type?(:lit, arg)
          mocha_expects_lit(exp, arg)
        else
          exp.original
        end
      end

      def mocha_expects_hash(exp, hash_sexp)
        assert_sexp_type(:hash, hash_sexp)
        pointless_lambda(hash_to_expectations(hash_sexp, exp.receiver))
      end

      def mocha_expects_lit(exp, lit_sexp)
        assert_sexp_type(:lit, lit_sexp)
        expect_to(receive_and_call_original(lit_sexp), exp.receiver, true)
      end

      # TODO: add support for
      # - at_least
      # - at_least_once
      # - at_most
      # - at_most_once
      # - never
      def mocha_expectation_count(exp, count)
        Type.assert(Model::Call, exp)
        Type.assert(Integer, count)
        receiver = mocha_stub_receiver(exp)
        any_instance = rspec_any_instance?(exp)
        message = mocha_stub_expects(exp).arguments.first
        with = mocha_stub_with(exp)
        returns = exp.find_call_in_receiver_chain(:returns)&.arguments&.first
        ExpressionBuilders::Stub.new(
          receiver, any_instance, message, with, returns, count
        ).to_rspec_exp
      end

      # Given a mocha stub, e.g. `X.any_instance.expects(:y)`, returns `X`.
      def mocha_stub_receiver(exp)
        chain = exp.receiver_chain
        last = chain[-1]
        last.nil? ? chain[-2] : last
      end

      # Given an `exp` representing a chain of calls, like
      # `stubs(x).returns(y).once`, finds the call to `stubs` or `expects`.
      def mocha_stub_expects(exp)
        exp.find_call_in_receiver_chain(%i[stubs expects])
      end

      def mocha_stub_with(exp)
        exp.find_call_in_receiver_chain(:with)&.arguments&.first
      end

      def rspec_any_instance?(exp)
        exp.calls_in_receiver_chain.any? { |i|
          i.method_name.to_s.include?('any_instance')
        }
      end

      def mocha_once(exp)
        mocha_expectation_count(exp, 1)
      end

      def mocha_stub(exp)
        raise ArgumentError unless exp.is_a?(Model::Call)
        if exp.receiver.nil?
          s(:call, nil, :double, *exp.arguments)
        else
          exp.original
        end
      end

      def mocha_twice(exp)
        mocha_expectation_count(exp, 2)
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
            0,
            s(:block,
              s(:str, 'Sorry for the pointless lambda here.'),
              *array_of_calls
            )
          ),
          :call
        )
      end

      def receive(message, with = [])
        r = s(:call, nil, :receive, message)
        if with.empty?
          r
        else
          s(:call, r, :with, *with)
        end
      end

      def receive_and_call_original(message)
        s(:call, s(:call, nil, :receive, message), :and_call_original)
      end

      def receive_and_return(message, return_values, with = [])
        s(:call, receive(message, with), :and_return, *return_values)
      end

      # `refsert` - Code shared by refute and assert. I could also have gone
      # with `assfute`. Wooo .. time for bed.
      def refsert(exact, fuzzy)
        actual = @exp.arguments[0]
        matcher = call_to_question_mark?(actual) ? exact : fuzzy
        expect_to(matcher, actual, true)
      end

      def require_spec_helper
        prefix = @rails ? 'rails' : 'spec'
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
