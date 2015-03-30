require "ruby_parser"
require "sexp_processor"
require_relative "subprocessors/call"
require_relative "subprocessors/class"

module MinitestToRspec
  class Processor < SexpProcessor
    def initialize
      super
      self.strict = false
    end

    def process_call(exp)
      Subprocessors::Call.process(exp)
    end

    def process_class(exp)
      Subprocessors::Class.process(exp)
    end
  end
end
