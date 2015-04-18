require_relative "../errors"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    class Class < Base
      class << self

        # Takes `exp`, a `:class` s-expression, and `rails`, a
        # boolean indicating that `rspec-rails` conventions (like
        # `:type` metadata) should be used.
        def process(exp, rails)
          @rails = rails
          raise ArgumentError unless exp.shift == :class
          name = exp.shift
          parent = exp.shift
          assert_valid_name(name)
          block = shift_into_block(exp)
          build(name, parent, block)
        end

        private

        def build(name, parent, block)
          result = build_root(name, parent)
          result.push(block) if block.length > 1
          result
        end

        def action_controller_test_case?(exp)
          lineage?(exp, [:ActionController, :TestCase])
        end

        def active_support_test_case?(exp)
          lineage?(exp, [:ActiveSupport, :TestCase])
        end

        def ancestor_name(exp, index)
          assert_sexp_type(:colon2, exp)
          ancestor = exp[index + 1]
          sexp_type?(:const, ancestor) ? ancestor[1] : ancestor
        end

        def assert_valid_name(name)
          if name.is_a?(Symbol)
            # noop. all is well
          elsif name.respond_to?(:sexp_type) && name.sexp_type == :colon2
            raise ModuleShorthandError
          else
            raise ProcessingError, "Unexpected class expression: #{name}"
          end
        end

        # Returns the root of the result: either an :iter representing
        # an `RSpec.describe` or, if it's not a test case, a :class.
        def build_root(name, parent)
          if parent && test_case?(parent)
            md = rspec_describe_metadata(parent)
            rspec_describe_block(name, md)
          else
            s(:class, name, parent)
          end
        end

        # Given a `test_class_name` like `BananaTest`, returns the
        # described class, like `Banana`.
        def described_class(test_class_name)
          test_class_name.to_s.gsub(/Test\Z/, "").to_sym
        end

        def lineage?(exp, names)
          assert_sexp_type(:colon2, exp)
          exp.length == names.length + 1 &&
            names.each_with_index.all? { |name, ix|
              name.to_sym == ancestor_name(exp, ix).to_sym
            }
        end

        def rspec_describe(arg, metadata)
          call = s(:call, s(:const, :RSpec), :describe, arg)
          unless metadata.nil?
            call << metadata
          end
          call
        end

        # Returns a S-expression representing a call to RSpec.describe
        def rspec_describe_block(name, metadata)
          const = s(:const, described_class(name))
          s(:iter, rspec_describe(const, metadata), s(:args))
        end

        def rspec_describe_metadata(exp)
          if @rails
            s(:hash, s(:lit, :type), s(:lit, rdm_type(exp)))
          else
            nil
          end
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
        def rdm_type(exp)
          if action_controller_test_case?(exp)
            :controller
          else
            :model
          end
        end

        def shift_into_block(exp)
          block = s(:block)
          until exp.empty?
            block << full_process(exp.shift)
          end
          block
        end

        # TODO: Obviously, there are other test case parent classes
        # not supported yet.
        def test_case?(exp)
          assert_sexp_type(:colon2, exp)
          active_support_test_case?(exp) || action_controller_test_case?(exp)
        end
      end
    end
  end
end
