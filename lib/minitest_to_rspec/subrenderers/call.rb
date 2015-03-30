require_relative "str"

module MinitestToRspec
  module Subrenderers
    class Call
      class << self
        def process(exp, buffer)
          exp.shift # type. unused, it's always :call
          exp.shift # the second element is a mystery
          buffer << exp.shift # method name
          process_arguments(exp, buffer)
          exp
        end

        private

        def process_arguments(exp, buffer)
          return if exp.length == 0
          buffer << "("
          until exp.empty?
            process_argument(exp.shift, buffer)
          end
          buffer << ")"
        end

        def process_argument(arg, buffer)
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
