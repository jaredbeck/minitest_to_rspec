# frozen_string_literal: true

require 'ruby_parser'
require 'ruby2ruby'
require 'minitest_to_rspec/input/processor'
require_relative 'errors'

module MinitestToRspec
  # Converts strings of minitest code. Does not read or write files.
  class Converter
    NEWLINE = '__NEWLINE__'

    def initialize(rails: false, mocha: false, newline: false)
      @processor = Input::Processor.new(rails, mocha)
      @newline = newline
    end

    # - `input` - Contents of a ruby file.
    # - `file_path` - Optional. Value will replace any `__FILE__`
    #   keywords in the input.
    def convert(input, file_path = nil)
      input = input.gsub("\n\n", "\n#{NEWLINE}\n") if @newline
      output = render process parse(input, file_path)
      output = output.gsub(NEWLINE, '') if @newline
      output
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
