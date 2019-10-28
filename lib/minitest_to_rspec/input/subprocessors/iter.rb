# frozen_string_literal: true

require 'minitest_to_rspec/input/subprocessors/base'
require 'minitest_to_rspec/input/model/iter'

module MinitestToRspec
  module Input
    module Subprocessors
      # Processes `s(:iter, ..)` expressions.
      class Iter < Base
        def initialize(sexp, rails, mocha)
          super(rails, mocha)
          @exp = Model::Iter.new(sexp)
          sexp.clear
        end

        def process
          process_exp(@exp)
        end

        private

        # Returns an expression representing an RSpec `change {}`
        # matcher.  See also `change_by` below.
        def change(exp)
          matcher_with_block(:change, exp)
        end

        # Returns an expression representing an RSpec `change {}.by()` matcher.
        def change_by(diff_exp, by_exp)
          s(:call,
            change(diff_exp),
            :by,
            by_exp
           )
        end

        def matcher_with_block(matcher_name, block)
          s(:iter,
            s(:call, nil, matcher_name),
            0,
            block
           )
        end

        def method_assert_difference(exp)
          call = exp[1]
          block = exp[3]
          by = call[4]
          what = parse(call[3][1])
          matcher = by.nil? ? change(what) : change_by(what, by)
          expect_to(matcher, block, false)
        end

        def method_assert_no_difference(exp)
          call = exp[1]
          block = exp[3]
          what = parse(call[3][1])
          expect_to_not(change(what), block, false)
        end

        def method_assert_nothing_raised(exp)
          block = exp[3]
          expect_to_not(raise_error, block, false)
        end

        def method_assert_raise(iter)
          method_assert_raises(iter)
        end

        def method_assert_raises(iter)
          expect_to(raise_error(*iter.call_arguments), iter.block, false)
        end

        def method_refute_raise(iter)
          method_refute_raises(iter)
        end

        def method_refute_raises(iter)
          expect_to_not(raise_error(*iter.call_arguments), iter.block, false)
        end

        def method_setup(exp)
          replace_method_name(exp, :before)
        end

        def method_teardown(exp)
          replace_method_name(exp, :after)
        end

        def name_of_processing_method(iter)
          method_name = iter[1][2]
          "method_#{method_name}".to_sym
        end

        def parse(str)
          RubyParser.new.parse(str)
        end

        # Given a `Model::Iter`, returns a `Sexp`
        def process_exp(exp)
          if processable?(exp)
            send_to_processing_method(exp)
          else
            process_uninteresting_iter(exp.sexp)
          end
        end

        def processable?(iter)
          if !iter.empty? && iter[1].sexp_type == :call
            method_name = iter[1][2]
            decision = "#{method_name}?".to_sym
            iter.respond_to?(decision) && iter.public_send(decision)
          else
            false
          end
        end

        def process_uninteresting_iter(exp)
          iter = s(exp.shift)
          until exp.empty?
            iter << full_process(exp.shift)
          end
          iter
        end

        # Given `args` which came from an `assert_raise` or an
        # `assert_raises`, return a `raise_error` matcher.
        # When the last argument is a string, it represents the
        # assertion failure message, and is discarded.
        def raise_error(*args)
          args.pop if !args.empty? && args.last.sexp_type == :str
          matcher(:raise_error, *args)
        end

        def replace_method_name(exp, new_method)
          iter = s(:iter, s(:call, nil, new_method))
          exp.each do |e| iter << full_process(e) end
          iter
        end

        def send_to_processing_method(exp)
          send(name_of_processing_method(exp), exp)
        end
      end
    end
  end
end
