# frozen_string_literal: true

require "ruby_parser"
require "ruby2ruby"
require_relative "processor"
require_relative "errors"

module MinitestToRspec
  class Converter
    def initialize(rails: false, mocha: false)
      @processor = Processor.new(rails, mocha)
    end

    # - `input` - Contents of a ruby file.
    # - `file_path` - Optional. Value will replace any `__FILE__`
    #   keywords in the input.
    def convert(input, file_path = nil)
      render process parse(input, file_path)
    end

    private

    # Parses input string and returns Abstract Syntax Tree (AST)
    # as an S-expression.
    def parse(input, file_path)
      file_path ||= "No file path provided to #{self.class}#convert"
      RubyParser.new.parse(input, file_path)
    end

    # Processes an AST (S-expressions) representing a minitest
    # file, and returns an AST (still S-expressions) representing
    # an rspec file.
    def process(exp)
      @processor.process(exp)
    end

    # Given an AST representing an rspec file, returns a string
    # of ruby code.
    def render(exp)
      renderer.process(exp)
    end

    def renderer
      Ruby2Ruby.new
    end
  end
end
