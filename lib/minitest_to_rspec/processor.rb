require "ruby_parser"
require "sexp_processor"
require_relative "subprocessors/call"

module MinitestToRspec
  class Processor < SexpProcessor
    def initialize
      super
      self.strict = false
    end

    def process_call(exp)
      Subprocessors::Call.process(exp)
    end
  end
end
