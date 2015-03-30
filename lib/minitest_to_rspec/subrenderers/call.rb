require_relative "const"
require_relative "str"

module MinitestToRspec
  module Subrenderers
    class Call
      class << self

        # Example S-expressions
        # ---------------------
        #
        # assert Banana.new.delicious?
        #
        # s(:call, nil, :assert,
        #   s(:call,
        #     s(:call, s(:const, :Banana), :new),
        #     :delicious?
        #   )
        # )
        #
        def process(exp, buffer)
          raise ArgumentError unless exp.shift == :call
          receiver = exp.shift
          unless receiver.nil?
            process_receiver(receiver, buffer)
            buffer << "."
          end
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
          case arg.sexp_type
          when :str
            Str.process(arg, buffer)
          when :call
            process(arg, buffer)
          when :const
            Const.process(arg, buffer)
          else
            raise "Unexpected argument type: #{arg.sexp_type}"
          end
        end

        def process_receiver(rvr, buffer)
          case rvr.sexp_type
          when :const
            Const.process(rvr, buffer)
          when :call
            process(rvr, buffer)
          else
            raise "Unexpected call receiver: #{rvr.sexp_type}"
          end
        end
      end
    end
  end
end
