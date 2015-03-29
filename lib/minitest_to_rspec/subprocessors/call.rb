module MinitestToRspec
  module Subprocessors

    # Examples of s(:call)
    # --------------------
    #
    # The following input examples
    #
    #     [:call, nil, :require, [:str, "test_helper"]]
    #     [:call, nil, :test, [:str, "is delicious"]]
    #
    # are processed into
    #
    #     [:call, nil, :require, [:str, "spec_helper"]]
    #     [:call, nil, :it, [:str, "is delicious"]]
    #
    class Call
      class << self
        def process(exp)
          orig = exp.dup
          type = exp.shift # unused, it's always :call, right?
          mystery = exp.shift # the second element is a mystery
          method_name = exp.shift
          result = case method_name
          when :test
            method_test(exp, mystery)
          when :require
            method_require(exp, orig, mystery)
          else
            orig
          end
          exp.clear
          result
        end

        private

        def method_require(exp, orig, mystery)
          if test_helper?(exp)
            s(:call, mystery, :require, s(:str, "spec_helper"))
          else
            orig
          end
        end

        def method_test(exp, mystery)
          if exp.length == 1 && exp[0].sexp_type == :str
            s(:call, mystery, :it, *exp)
          end
        end

        def test_helper?(exp)
          exp.length == 1 &&
            exp[0].sexp_type == :str &&
            exp[0][1] == "test_helper"
        end
      end
    end
  end
end
