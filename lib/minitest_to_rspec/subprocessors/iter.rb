require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Iter < Base
      class << self
        def process(sexp)
          unless sexp.sexp_type == :iter
            raise ArgumentError, "Expected iter, got #{sexp.sexp_type}"
          end
          exp = sexp.dup
          sexp.clear
          if assert_difference_iter?(exp)
            process_assert_difference(exp[1], exp[3])
          else
            process_uninteresting_iter(exp)
          end
        end

        private

        def assert_difference_call?(exp)
          exp.length == 5 &&
            exp.sexp_type == :call &&
            exp[2] == :assert_difference &&
            exp[3].sexp_type == :str &&
            exp[4].sexp_type == :lit
        end

        def assert_difference_iter?(exp)
          exp.length > 1 && assert_difference_call?(exp[1])
        end

        # Returns an expression representing an RSpec `change {}.by()` matcher.
        def change_by(diff_exp, by_exp)
          s(:call,
            matcher_with_block(:change, diff_exp),
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

        def process_assert_difference(call, block)
          by_exp = call[4]
          diff_str = call[3][1]
          diff_exp = RubyParser.new.parse(diff_str)
          s(:call,
            expectation_target_with_block(block),
            :to,
            change_by(diff_exp, by_exp)
          )
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
