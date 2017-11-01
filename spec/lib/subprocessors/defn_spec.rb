require "spec_helper"
require "ruby_parser"
require 'helpers'

module MinitestToRspec
  module Subprocessors
    RSpec.describe Defn do
      include Helpers

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

      describe '#generate_block' do
        it 'returns a sexp block and inner logic' do
          ruby = <<-RUBY
            def test_method_name
              assert_equal 1, 1
            end
          RUBY

          allow_any_instance_of(::MinitestToRspec::Model::Defn)
            .to receive(:innards).and_return(s(parse('assert_equal 1, 1')))
          sexp = RubyParser.new.parse(ruby)
          generated_block = described_class.new(sexp, false, false).send(:generate_block)
          expect(generated_block.first).to eq(:block)
          expect(generated_block).to include(parse('expect(1).to(eq(1))'))
        end
      end
    end
  end
end
