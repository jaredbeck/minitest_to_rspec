# frozen_string_literal: true

require "spec_helper"
require "ruby_parser"

module MinitestToRspec
  module Model
    RSpec.describe Defn do
      describe '#body' do
        it 'returns sexp' do
          method = <<-RUBY
            def method_name
              inner_method
            end
          RUBY
          sexp = RubyParser.new.parse(method)
          expect(described_class.new(sexp).body)
            .to eq(s(s(:call, nil, :inner_method)))
        end
      end

      describe '#method_name' do
        it 'returns the method name as a string' do
          sexp = s(:defn, :method_name)
          expect(described_class.new(sexp).method_name).to eq('method_name')
        end
      end

      describe '#test_method?' do
        context 'method name begins with test_' do
          it 'returns true' do
            sexp = s(:defn, :test_banana)
            expect(described_class.new(sexp)).to be_test_method
          end
        end
      end
    end
  end
end
