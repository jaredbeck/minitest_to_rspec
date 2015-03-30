module MinitestToRspec
  module Subrenderers
    class Const
      class << self
        def process(exp, buffer)
          assert_equal(:const, exp.shift)
          name = exp.shift
          raise "Unexpected const expression" unless exp.empty?
          buffer << name
        end

        private

        def assert_equal(expected, calculated)
          unless expected == calculated
            raise("Expected #{expected}, got #{calculated}")
          end
        end
      end
    end
  end
end
