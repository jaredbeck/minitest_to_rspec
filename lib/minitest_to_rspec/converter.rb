require "ruby_parser"
require "sexp2ruby"
require_relative "processor"
require_relative "errors"

module MinitestToRspec
  class Converter
    NO_PAREN_METHODS = %i[
      context
      delete
      describe
      get
      include
      it
      post
      put
      require
      to
      to_not
    ]

    def initialize(options)
      @options = options
      @processor = Processor.new(@options[:rails])
    end

    def convert(input)
      render process parse input
    end

    private

    # Parses input string and returns Abstract Syntax Tree (AST)
    # as an S-expression.
    def parse(input)
      RubyParser.new.parse(input)
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
      Sexp2Ruby::Processor.new(
        hash_syntax: :ruby19,
        no_paren_methods: NO_PAREN_METHODS
      )
    end
  end
end
