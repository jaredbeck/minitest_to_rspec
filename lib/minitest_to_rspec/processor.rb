require "ruby_parser"
require "sexp_processor"

module MinitestToRspec
  class Processor < SexpProcessor
    def initialize
      super
      self.strict = false
    end

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
    def process_call(exp)
      orig = exp.dup
      type = exp.shift # unused, it's always :call, right?
      mystery = exp.shift # the second element is a mystery
      method_name = exp.shift
      case method_name
      when :test
        if exp.length == 1 && exp[0].sexp_type == :str
          s(:call, mystery, :it, exp.shift)
        else
          raise <<-EOS
Expected test() to have exactly one argument, a string.  Found
#{exp.length} arguments: #{exp}
          EOS
        end
      when :require
        if exp.length == 1 && exp[0].sexp_type == :str && exp[0][1] == "test_helper"
          exp.clear
          s(:call, mystery, :require, s(:str, "spec_helper"))
        else
          exp.clear
          orig
        end
      else
        exp.clear
        orig
      end
    end
  end
end
