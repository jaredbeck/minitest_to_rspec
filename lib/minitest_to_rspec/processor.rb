# frozen_string_literal: true

require "ruby_parser"
require "sexp_processor"
require_relative "subprocessors/call"
require_relative "subprocessors/defn"
require_relative "subprocessors/klass"
require_relative "subprocessors/iter"

module MinitestToRspec
  class Processor < SexpProcessor
    def initialize(rails, mocha)
      super()
      self.strict = false
      @mocha = mocha
      @rails = rails
    end

    def process_call(exp)
      Subprocessors::Call.new(exp, @rails, @mocha).process
    end

    def process_class(exp)
      Subprocessors::Klass.new(exp, @rails, @mocha).process
    end

    def process_defn(exp)
      Subprocessors::Defn.new(exp, @rails, @mocha).process
    end

    def process_iter(exp)
      Subprocessors::Iter.new(exp, @rails, @mocha).process
    end
  end
end
