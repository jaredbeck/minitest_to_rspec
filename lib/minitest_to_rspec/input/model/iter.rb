# frozen_string_literal: true

require 'minitest_to_rspec/input/model/base'

module MinitestToRspec
  module Input
    module Model
      # Data object.  Represents an `:iter` s-expression.
      class Iter < Base
        def initialize(exp)
          assert_sexp_type(:iter, exp)
          @exp = exp.dup
        end

        def [](*args)
          @exp[*args]
        end

        def assert_difference?
          !empty? && Model::Call.assert_difference?(@exp[1])
        end

        def assert_no_difference?
          !empty? && Model::Call.assert_no_difference?(@exp[1])
        end

        def assert_nothing_raised?
          !empty? && Model::Call.assert_nothing_raised?(@exp[1])
        end

        def assert_raise?
          !empty? && Model::Call.assert_raise?(@exp[1])
        end

        def assert_raises?
          !empty? && Model::Call.assert_raises?(@exp[1])
        end

        def refute_raise?
          !empty? && Model::Call.refute_raise?(@exp[1])
        end

        def refute_raises?
          !empty? && Model::Call.refute_raises?(@exp[1])
        end

        def block
          @exp[3]
        end

        def call
          @exp[1]
        end

        # Not to be confused with block arguments.
        def call_arguments
          call_obj.arguments
        end

        def call_obj
          Model::Call.new(call)
        end

        # Enumerates children, skipping the base `call` and
        # starting with the block arguments, then each `:call` in
        # the block.
        def each
          @exp[2..-1].each do |e| yield(e) end
        end

        def empty?
          @exp.length == 1 # just the sexp_type
        end

        def setup?
          !empty? && Model::Call.method_name?(@exp[1], :setup)
        end

        def teardown?
          !empty? && Model::Call.method_name?(@exp[1], :teardown)
        end

        def sexp
          @exp
        end
      end
    end
  end
end
