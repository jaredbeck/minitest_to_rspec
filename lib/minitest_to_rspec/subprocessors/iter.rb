require_relative "base"
require_relative "../exp/iter"

module MinitestToRspec
  module Subprocessors
    class Iter < Base
      class << self
        def process(sexp)
          exp = Exp::Iter.new(sexp)
          sexp.clear
          process_exp(exp)
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

        # In RSpec, `expect` returns an "expectation target".  This
        # can be based on an expression, as in `expect(1 + 1)` or it
        # can be based on a block, as in `expect { raise }`.  Either
        # way, it's called an "expectation target".
        def expectation_target_with_block(block)
          s(:iter,
            s(:call, nil, :expect),
            s(:args),
            full_process(block)
          )
        end

        def matcher_with_block(matcher_name, block)
          s(:iter,
            s(:call, nil, matcher_name),
            s(:args),
            block
          )
        end

        def parse(str)
          RubyParser.new.parse(str)
        end

        def process_assert_difference(exp, phase)
          call = exp[1]
          block = exp[3]
          processing_method = "process_assert_%s_difference" % [
            phase ? "yes" : "no"
          ]
          send(processing_method, call, block)
        end

        def process_assert_yes_difference(call, block)
          by = call[4]
          what = parse(call[3][1])
          matcher = by.nil? ? change(what) : change_by(what, by)
          s(:call, expectation_target_with_block(block), :to, matcher)
        end

        def process_assert_no_difference(call, block)
          what = parse(call[3][1])
          s(:call, expectation_target_with_block(block), :to_not, change(what))
        end

        def process_assert_nothing_raised(exp)
          block = exp[3]
          s(:call, expectation_target_with_block(block), :to_not, raise_error)
        end

        def process_assert_raises(exp)
          block = exp[3]
          call = Exp::Call.new(exp[1])
          err = call.arguments.first
          s(:call, expectation_target_with_block(block), :to, raise_error(err))
        end

        def process_exp(exp)
          if exp.assert_difference?
            process_assert_difference(exp.sexp, true)
          elsif exp.assert_no_difference?
            process_assert_difference(exp.sexp, false)
          elsif exp.assert_raises?
            process_assert_raises(exp.sexp)
          elsif exp.assert_nothing_raised?
            process_assert_nothing_raised(exp.sexp)
          else
            process_uninteresting_iter(exp.sexp)
          end
        end

        def process_uninteresting_iter(exp)
          iter = s(exp.shift)
          until exp.empty?
            iter << full_process(exp.shift)
          end
          iter
        end

        def raise_error(*args)
          matcher(:raise_error, *args)
        end
      end
    end
  end
end
