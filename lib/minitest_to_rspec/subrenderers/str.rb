module MinitestToRspec
  module Subrenderers
    class Str
      QU_S = "'"
      QU_D = '"'

      class << self
        def process(exp, buffer)
          raise ArgumentError unless exp.shift == :str
          unless exp.length == 1
            raise "Sorry, don't know how to render that string yet"
          end
          buffer << quote(exp.shift)
          exp
        end

        private

        def quote(str)
          case quote_style(str)
          when :single
            quote_single(str)
          when :double
            quote_double(str)
          else :percent_q
            quote_percent_q(str)
          end
        end

        def quote_double(str)
          '"%s"' % str
        end

        def quote_percent_q(str)
          "%q(#{str})"
        end

        def quote_single(str)
          "'%s'" % str
        end

        def quote_style(str)
          s = str.include?(QU_S)
          d = str.include?(QU_D)
          if s && d
            :percent_q
          elsif d
            :single
          else
            :double
          end
        end
      end
    end
  end
end
