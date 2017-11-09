# frozen_string_literal: true

require 'spec_helper'

module MinitestToRspec
  class ClassWithSexpAssertions
    extend SexpAssertions
  end

  RSpec.describe ClassWithSexpAssertions do
    def expect_type_error(message)
      expect { yield }.to raise_error(TypeError, message)
    end

    describe '.assert_sexp_type' do
      context 'nil' do
        it 'raises TypeError' do
          expect_type_error('Expected derp s-expression, got nil') {
            described_class.assert_sexp_type(:derp, nil)
          }
        end
      end

      context 'wrong sexp_type' do
        it 'raises TypeError, inspects sexp' do
          expect_type_error('Expected foo s-expression, got s(:bar)') {
            described_class.assert_sexp_type(:foo, s(:bar))
          }
        end
      end
    end

    describe '.assert_sexp_type_array' do
      context 'nil' do
        it 'raises TypeError' do
          expect_type_error('Expected array of foo sexp, got nil') {
            described_class.assert_sexp_type_array(:foo, nil)
          }
        end
      end
    end
  end
end
