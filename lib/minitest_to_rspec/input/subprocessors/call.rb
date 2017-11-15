# frozen_string_literal: true

require 'minitest_to_rspec/input/model/call'
require 'minitest_to_rspec/input/model/hash_exp'
require 'minitest_to_rspec/input/subprocessors/base'
require 'minitest_to_rspec/minitest/stub'
require 'minitest_to_rspec/rspec/stub'
require 'minitest_to_rspec/type'

module MinitestToRspec
  module Input
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
          if @exp.num_arguments == 1 &&
             %i[lit hash].include?(@exp.arguments.first.sexp_type)
            mocha_stub
          else
            @exp.original
          end
        end

        def method_once
          mocha_stub
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
          if @exp.num_arguments.zero?
            @exp.original
          else
            mocha_stub
          end
        end

        def method_require
          if @exp.require_test_helper?
            require_spec_helper
          else
            @exp.original
          end
        end

        def method_should
          s(:call, nil, :it, *@exp.arguments)
        end

        # Happily, the no-block signatures of [stub][3] are the
        # same as [double][2].
        #
        # - (name)
        # - (stubs)
        # - (name, stubs)
        def method_stub
          raise ArgumentError unless @exp.is_a?(Model::Call)
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
            s(:call, d, :as_null_object)
          else
            @exp.original
          end
        end

        def method_test
          s(:call, nil, :it, *@exp.arguments)
        end

        def method_twice
          mocha_stub
        end

        # Given a sexp representing the hash from a mocha shorthand stub, as in
        # `Banana.expects(edible: true, color: "yellow")`
        # return an array of separate RSpec stubs, one for each hash key.
        def mocha_shorthand_stub_to_rspec_stubs(shorthand_stub_hash, mt_stub)
          Model::HashExp.new(shorthand_stub_hash).to_h.map { |k, v|
            Rspec::Stub.new(
              mt_stub.receiver,
              mt_stub.any_instance?,
              k,
              mt_stub.with,
              v,
              1
            ).to_rspec_exp
          }
        end

        def mocha_stub
          mt_stub = Minitest::Stub.new(@exp)
          msg = mt_stub.message
          if sexp_type?(:hash, msg)
            pointless_lambda(mocha_shorthand_stub_to_rspec_stubs(msg, mt_stub))
          else
            Rspec::Stub.new(
              mt_stub.receiver,
              mt_stub.any_instance?,
              mt_stub.message,
              mt_stub.with,
              mt_stub.returns,
              mt_stub.count
            ).to_rspec_exp
          end
        rescue StandardError
          # TODO: We used to have an `UnknownVariant` error.
          # That was nice and specific.
          @exp.original
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
        # `s(:block, s(:block, ..))`) which `ruby2ruby` (naturally) does not
        # know how to process.  So, the easiest solution I could think of is a
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
end

# [1]: http://bit.ly/1yll6ND
# [2]: http://bit.ly/1CRdmP3
# [3]: http://bit.ly/1aY2mJN
# [4]: http://bit.ly/1OtwDOY
