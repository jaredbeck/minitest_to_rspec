# frozen_string_literal: true

require_relative '../errors'
require_relative '../model/klass'
require_relative 'base'

module MinitestToRspec
  module Subprocessors
    # Processes `s(:class, ..)` expressions.
    class Klass < Base
      # Takes `sexp`, a `:class` s-expression, and `rails`, a
      # boolean indicating that `rspec-rails` conventions (like
      # `:type` metadata) should be used.
      def initialize(sexp, rails, mocha)
        super(rails, mocha)
        @exp = Model::Klass.new(sexp)
        sexp.clear
      end

      def process
        sexp = head
        ebk = @exp.block
        if ebk.length > 1
          sexp << block
        elsif ebk.length == 1
          sexp << full_process(ebk[0])
        end
        sexp
      end

      private

      # Returns a :block S-expression, the contents of the class.
      def block
        processed = @exp.block.map { |line| full_process(line) }
        s(:block, *processed)
      end

      # Given a `test_class_name` like `BananaTest`, returns the
      # described class, like `Banana`.
      def described_class(test_class_name)
        test_class_name.to_s.gsub(/Test\Z/, '').to_sym
      end

      # Returns the head of the output Sexp.  If it's a test case,
      # an :iter representing an `RSpec.describe`.  Otherwise, a :class.
      def head
        if @exp.test_case?
          rspec_describe_block
        else
          s(:class, @exp.name, @exp.parent)
        end
      end

      # Returns an S-expression representing the
      # RDM (RSpec Describe Metadata) hash
      def rdm
        s(:hash, s(:lit, :type), s(:lit, rdm_type))
      end

      # Returns the RDM (RSpec Describe Metadata) type.
      #
      # > Model specs: type: :model
      # > Controller specs: type: :controller
      # > Request specs: type: :request
      # > Feature specs: type: :feature
      # > View specs: type: :view
      # > Helper specs: type: :helper
      # > Mailer specs: type: :mailer
      # > Routing specs: type: :routing
      # > http://bit.ly/1G5w7CJ
      #
      # TODO: Obviously, they're not all supported yet.
      def rdm_type
        if @exp.action_controller_test_case?
          :controller
        elsif @exp.draper_test_case?
          :decorator
        elsif @exp.action_mailer_test_case?
          :mailer
        else
          :model
        end
      end

      def rspec_describe
        const = s(:const, described_class(@exp.name))
        call = s(:call, s(:const, :RSpec), :describe, const)
        call << rdm if @rails
        call
      end

      # Returns a S-expression representing a call to RSpec.describe
      def rspec_describe_block
        s(:iter, rspec_describe, 0)
      end
    end
  end
end
