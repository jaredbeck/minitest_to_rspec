require "ruby_parser"
require_relative "processor"

module MinitestToRspec
  class Converter
    def initialize
      @processor = Processor.new
    end

    def convert(input)
      render process parse input
    end

    private

    # Parses an input string using the `ruby_parser` gem, and
    # returns an Abstract Syntax Tree (AST) in the form of
    # S-expressions.
    def parse(input)
      RubyParser.new.parse(input)
    end

    # Processes an AST (S-expressions) representing a minitest
    # file, and returns an AST (still S-expressions) representing
    # an rspec file.
    def process(sexp)
      @processor.process(sexp)
    end

    # Given an AST representing an rspec file, returns a string
    # of ruby code.
    def render(sexp)
      sexp # TODO: Render ruby code
    end
  end
end
