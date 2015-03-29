require_relative "str"

module MinitestToRspec
  module Subrenderers
    class Call
      class << self
        def process(exp, buffer)
          exp.shift # type. unused, it's always :call
          exp.shift # the second element is a mystery
          buffer << exp.shift # method name
          buffer << "("
          process_arguments(exp, buffer)
          buffer << ")"
          exp
        end

        private

        def process_arguments(exp, buffer)
          until exp.empty?
            arg = exp.shift
            if arg.sexp_type == :str
              Str.process(arg, buffer)
            elsif arg.sexp_type == :call
              process(arg, buffer)
            else
              raise "Unexpected argument type: #{arg.sexp_type}"
            end
          end
        end
      end
    end
  end
end
