require "ruby_parser"
require "ruby2ruby"
require_relative "processor"
require_relative "errors"

module MinitestToRspec
  class Converter
    def initialize(options)
      @options = options
      @processor = Processor.new(@options[:rails_helper])
    end

    def convert(input)
      render process parse input
    end

    private

    # Parses an input string using the `ruby_parser` gem, and
    # returns an Abstract Syntax Tree (AST) in the form of
    # S-expressions.
    #
    # Example of AST
    # --------------
    #
    # s(:block,
    #   s(:call, nil, :require, s(:str, "test_helper")),
    #   s(:class,
    #     :BananaTest,
    #     s(:colon2, s(:const, :ActiveSupport), :TestCase),
    #     s(:iter,
    #       s(:call, nil, :test, s(:str, "is delicious")),
    #       s(:args),
    #       s(:call, nil, :assert,
    #         s(:call, s(:call, s(:const, :Banana), :new), :delicious?)
    #       )
    #     )
    #   )
    # )
    #
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
      ruby2ruby.process(exp)
    end

    def ruby2ruby
      Ruby2Ruby.new(hash_syntax: :ruby19)
    rescue ArgumentError
      Ruby2Ruby.new
    end
  end
end
