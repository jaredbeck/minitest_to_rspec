# frozen_string_literal: true

require 'minitest_to_rspec/input/processor'
require 'minitest_to_rspec/input/subprocessors/base'
require 'minitest_to_rspec/input/model/defn'

module MinitestToRspec
  module Input
    module Subprocessors
      # Minitest tests can be defined as methods using names beginning with
      # 'test_'. Process those tests into RSpec `it` example blocks.
      class Defn < Base
        def initialize(sexp, rails, mocha)
          super(rails, mocha)
          @original = sexp.dup
          @exp = Model::Defn.new(sexp)
          sexp.clear
        end

        # Using a `Model::Defn`, returns a `Sexp`
        def process
          if @exp.test_method?
            s(:iter,
              s(:call, nil, :it, s(:str, example_title)),
              0,
              example_block)
          elsif @exp.setup?
            s(:iter,
              s(:call, nil, :before),
              0,
              example_block
             )
          elsif @exp.teardown?
            s(:iter,
              s(:call, nil, :after),
              0,
              example_block
             )
          else
            @original
          end
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
          Processor.new(@rails, @mocha).process(line)
        end
      end
    end
  end
end
