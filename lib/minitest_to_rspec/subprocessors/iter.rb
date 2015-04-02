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

        def process_assert_difference(exp)
          call = exp[1]
          block = exp[3]
          by = call[4]
          what = parse(call[3][1])
          matcher = by.nil? ? change(what) : change_by(what, by)
          s(:call, expectation_target_with_block(block), :to, matcher)
        end

        def process_assert_no_difference(exp)
          call = exp[1]
          block = exp[3]
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

        # Given a `Exp::Iter`, returns a `Sexp`
        def process_exp(exp)
          m = processing_method(exp)
          if m.nil?
            process_uninteresting_iter(exp.sexp)
          else
            send(m, exp)
          end
        end

        def process_uninteresting_iter(exp)
          iter = s(exp.shift)
          until exp.empty?
            iter << full_process(exp.shift)
          end
          iter
        end

        # Returns the name of a method in this subprocessor, or nil if
        # this iter is not processable.
        def processing_method(iter)
          if !iter.empty? && iter[1].sexp_type == :call
            method_name = iter[1][2]
            decision = "#{method_name}?".to_sym
            if iter.respond_to?(decision) && iter.public_send(decision)
              "process_#{method_name}".to_sym
            end
          end
        end

        def raise_error(*args)
          matcher(:raise_error, *args)
        end
      end
    end
  end
end
