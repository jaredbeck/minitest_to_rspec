require "ruby_parser"
require "sexp_processor"
require_relative "subprocessors/call"
require_relative "subprocessors/class"
require_relative "subprocessors/iter"

module MinitestToRspec
  class Processor < SexpProcessor
    def initialize(rails)
      super()
      self.strict = false
      @rails = rails
    end

    def process_call(exp)
      Subprocessors::Call.process(exp, @rails)
    end

    def process_class(exp)
      Subprocessors::Class.process(exp, @rails)
    end

    def process_iter(exp)
      Subprocessors::Iter.process(exp)
    end
  end
end
