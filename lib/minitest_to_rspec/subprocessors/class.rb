require_relative "../errors"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Class < Base
      class << self
        def process(exp)
          raise ArgumentError unless exp.shift == :class
          name = exp.shift
          parent = exp.shift
          iter = exp.empty? ? nil : exp.shift
          unless exp.empty?
            raise("Unexpected class expression")
          end
          assert_valid_name(name)
          result(name, parent, iter)
        end

        private

        def active_support_test_case?(parent)
          parent.length == 3 &&
            parent[1] == s(:const, :ActiveSupport) &&
            parent[2] == :TestCase
        end

        def assert_valid_name(name)
          if name.is_a?(Symbol)
            # noop. all is well
          elsif name.sexp_type == :colon2
            raise ModuleShorthandError
          else
            raise ProcessingError, "Unexpected class expression: #{name}"
          end
        end

        # Given a `test_class_name` like `BananaTest`, returns the
        # described clas, like `Banana`.
        def described_class(test_class_name)
          test_class_name.to_s.gsub(/Test\Z/, "").to_sym
        end

        def inheritance?(exp)
          exp.sexp_type == :colon2
        end

        # Run `exp` through a new `Processor`.  This is appropriate
        # for expressions like `:iter` (a block) which we're not
        # interested in processing.  We *are* interested in
        # processing expressions within an `:iter`, but not the
        # iter itself.  TODO: `full_process` may not be the best name.
        def full_process(exp)
          Processor.new.process(exp)
        end

        def result(name, parent, iter)
          if parent && test_case?(parent)
            rspec_describe_block(name, iter)
          elsif iter.nil?
            s(:class, name, parent)
          else
            s(:class, name, parent, full_process(iter))
          end
        end

        def rspec_describe(arg)
          s(:call, s(:const, :RSpec), :describe, arg)
        end

        # Returns a S-expression representing a call to RSpec.describe
        def rspec_describe_block(name, iter)
          arg = s(:const, described_class(name))
          result = s(:iter, rspec_describe(arg), s(:args))
          unless iter.nil?
            result << full_process(iter)
          end
          result
        end

        # TODO: Obviously, there are test case parent classes
        # other than ActiveSupport::TestCase
        def test_case?(parent)
          raise ArgumentError unless inheritance?(parent)
          active_support_test_case?(parent)
        end
      end
    end
  end
end
