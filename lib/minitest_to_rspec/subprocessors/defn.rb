# frozen_string_literal: true

require_relative "../model/defn"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    # Minitest tests can be defined as methods using names beginning with
    # 'test_'. Process those tests into RSpec `it` example blocks.
    class Defn < Base
      def initialize(sexp, rails, mocha)
        super(rails, mocha)
        @exp = Model::Defn.new(sexp)
        sexp.clear
      end

      # Using a `Model::Defn`, returns a `Sexp`
      def process
        s(:iter,
          s(:call, nil, :it, s(:str, example_title)),
          0,
          example_block)
      end

      private

      # Remove 'test_' prefix and replace underscores with spaces
      def example_title
        @exp.method_name.sub(/^test_/, '').tr('_', ' ')
      end

      def example_block
        block = s(:block)
        @exp.body.each_with_object(block) do |line, blk|
          blk << process_line(line)
        end
      end

      def process_line(line)
        ::MinitestToRspec::Processor.new(@rails, @mocha).process(line)
      end
    end
  end
end
