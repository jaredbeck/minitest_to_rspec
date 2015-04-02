require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Iter < Base
      class << self
        def process(sexp)
          assert_iter(sexp)
          exp = sexp.dup
          sexp.clear
          process_exp(exp)
        end

        private

        def assert_difference?(exp)
          exp.length > 1 && Exp::Call.assert_difference?(exp[1])
        end

        def assert_iter(sexp)
          unless sexp.sexp_type == :iter
            raise ArgumentError, "Expected iter, got #{sexp.sexp_type}"
          end
        end

        def assert_no_difference?(exp)
          exp.length > 1 && Exp::Call.assert_no_difference?(exp[1])
        end

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
          if phase
            process_assert_yes_difference(call, block)
          else
            process_assert_no_difference(call, block)
          end
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

        def process_exp(exp)
          if assert_difference?(exp)
            process_assert_difference(exp, true)
          elsif assert_no_difference?(exp)
            process_assert_difference(exp, false)
          else
            process_uninteresting_iter(exp)
          end
        end

        def process_uninteresting_iter(exp)
          iter = s(exp.shift)
          until exp.empty?
            iter << full_process(exp.shift)
          end
          iter
        end
      end
    end
  end
end
