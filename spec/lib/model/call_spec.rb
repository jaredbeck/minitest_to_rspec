# frozen_string_literal: true

require 'spec_helper'

module MinitestToRspec
  module Model
    RSpec.describe Call do
      def parse(exp)
        RubyParser.new.parse(exp)
      end

      describe '.new' do
        context 'sexp_type is not :call' do
          it 'raises TypeError' do
            expect {
              described_class.new(s(:str, 'derp'))
            }.to raise_error(TypeError)
          end
        end
      end

      describe '#receiver_chain' do
        def receiver_chain(exp)
          described_class.new(exp).receiver_chain
        end

        it 'returns array' do
          expect(receiver_chain(parse('@a.b.c'))).to eq(
            [parse('@a.b'), parse('@a')]
          )
        end

        it 'returns array' do
          expect(receiver_chain(parse('@a.b(1, :x).c(2, 3)'))).to eq(
            [parse('@a.b(1, :x)'), parse('@a')]
          )
        end

        context 'when leaf sexp is a call with nil receiver' do
          it 'includes the nil receiver' do
            expect(receiver_chain(parse('a.b.c'))).to eq(
              [parse('a.b'), parse('a'), nil]
            )
          end
        end
      end
    end
  end
end
