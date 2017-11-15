# frozen_string_literal: true

require 'minitest_to_rspec/type'

module MinitestToRspec
  module Rspec
    # Represents an `expects` or a `stubs`
    class Stub
      def initialize(receiver, any_instance, message, with, returns, count)
        Type.assert(Sexp, receiver)
        Type.bool(any_instance)
        Type.assert(Sexp, message)
        Type.assert([NilClass, Sexp], with)
        Type.assert([NilClass, Sexp], returns)
        Type.assert([NilClass, Integer], count)
        @receiver = receiver
        @any_instance = any_instance
        @message = message
        @with = with
        @returns = returns
        @count = count
      end

      # Returns a Sexp representing an RSpec stub (allow) or message
      # expectation (expect)
      def to_rspec_exp
        stub_chain = s(:call, nil, :receive, @message)
        unless @with.nil?
          stub_chain = s(:call, stub_chain, :with, @with)
        end
        unless @returns.nil?
          stub_chain = s(:call, stub_chain, :and_return, @returns)
        end
        unless @count.nil?
          stub_chain = s(:call, stub_chain, receive_count_method)
        end
        expect_allow = s(:call, nil, rspec_mocks_method, @receiver.dup)
        s(:call, expect_allow, :to, stub_chain)
      end

      private

      def receive_count_method
        case @count
        when 1
          :once
        when 2
          :twice
        else
          raise "Unsupported message receive count: #{@count}"
        end
      end

      # Returns :expect or :allow
      def rspec_mocks_method
        prefix = @count.nil? ? 'allow' : 'expect'
        suffix = @any_instance ? '_any_instance_of' : ''
        (prefix + suffix).to_sym
      end
    end
  end
end
