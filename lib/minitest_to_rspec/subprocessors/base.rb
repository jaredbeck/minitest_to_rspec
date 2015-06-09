require_relative "../sexp_assertions"

module MinitestToRspec
  module Subprocessors
    class Base
      include SexpAssertions

      # Returns a s-expression representing an rspec-mocks stub.
      def allow_to(msg_recipient, matcher, any_instance = false)
        allow_method = any_instance ? :allow_any_instance_of : :allow
        target = s(:call, nil, allow_method, msg_recipient)
        s(:call, target, :to, matcher)
      end

      # Returns a s-expression representing an RSpec expectation, i.e. the
      # combination of an "expectation target" and a matcher.
      def expect(target, eager, phase, matcher, any_instance)
        et = expectation_target(target, eager, any_instance)
        s(:call, et, phase, matcher)
      end

      def expect_to(matcher, target, eager, any_instance = false)
        expect(target, eager, :to, matcher, any_instance)
      end

      def expect_to_not(matcher, target, eager)
        expect(target, eager, :to_not, matcher, false)
      end

      # In RSpec, `expect` returns an "expectation target".  This
      # can be based on an expression, as in `expect(1 + 1)` or it
      # can be based on a block, as in `expect { raise }`.  Either
      # way, it's called an "expectation target".
      def expectation_target(exp, eager, any_instance)
        if eager
          expectation_target_eager(exp, any_instance)
        else
          expectation_target_lazy(exp)
        end
      end

      def expectation_target_eager(exp, any_instance)
        expect_method = any_instance ? :expect_any_instance_of : :expect
        s(:call, nil, expect_method, exp)
      end

      def expectation_target_lazy(block)
        s(:iter,
          s(:call, nil, :expect),
          0,
          full_process(block)
        )
      end

      # If it's a `Sexp`, run `obj` through a new `Processor`.  Otherwise,
      # return `obj`.
      #
      # This is useful for expressions that cannot be fully understood by a
      # single subprocessor.  For example, we must begin processing all :iter
      # expressions, because some :iter represent calls we're interested in,
      # e.g. `assert_difference`.  However, if the :iter turns out to be
      # uninteresting (perhaps it has no assertions) we still want to fully
      # process its sub-expressions.
      #
      # TODO: `full_process` may not be the best name.
      def full_process(obj)
        obj.is_a?(Sexp) ? Processor.new(false).process(obj) : obj
      end

      def matcher(name, *args)
        exp = s(:call, nil, name)
        exp.concat(args)
      end
    end
  end
end
