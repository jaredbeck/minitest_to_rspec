# frozen_string_literal: true

require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Subprocessors
    RSpec.describe Defn do
      def parse(exp)
        RubyParser.new.parse(exp)
      end

      describe '.new' do
        context 'sexp_type is not :defn' do
          it 'raises TypeError' do
            expect { described_class.new(s(:str, 'derp'), false, false) }
              .to raise_error(TypeError)
          end
        end
      end

      describe '#example_title' do
        it 'parses the method name' do
          sexp = s(:defn, :test_method_name)
          expect(described_class.new(sexp, false, false).send(:example_title))
            .to eq('method name')
        end
      end

      describe '#example_block' do
        it 'returns a sexp block and inner logic' do
          ruby = <<-RUBY
            def test_method_name
              assert_equal 1, 1
            end
          RUBY

          allow_any_instance_of(::MinitestToRspec::Model::Defn)
            .to receive(:body).and_return(s(parse('assert_equal 1, 1')))
          sexp = RubyParser.new.parse(ruby)
          example_block = described_class.new(sexp, false, false).send(:example_block)
          expect(example_block.first).to eq(:block)
          expect(example_block).to include(parse('expect(1).to(eq(1))'))
        end
      end
    end
  end
end
