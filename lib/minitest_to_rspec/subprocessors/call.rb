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
          raise ArgumentError unless exp.shift == :call
          receiver = exp.shift
          method_name = exp.shift
          result = case method_name
          when :test
            method_test(exp, receiver)
          when :require
            method_require(exp, orig, receiver)
          else
            orig
          end
          exp.clear
          result
        end

        private

        def method_require(exp, orig, receiver)
          if test_helper?(exp)
            s(:call, receiver, :require, s(:str, "spec_helper"))
          else
            orig
          end
        end

        def method_test(exp, receiver)
          if exp.length == 1 && string?(exp[0])
            s(:call, receiver, :it, *exp)
          end
        end

        def string?(exp)
          exp.sexp_type == :str
        end

        def test_helper?(exp)
          exp.length == 1 &&
            string?(exp[0]) &&
            exp[0][1] == "test_helper"
        end
      end
    end
  end
end
