require_relative "../errors"

module MinitestToRspec
  module Subprocessors
    class Class
      class << self

        # Examples of S-expressions
        # -------------------------
        #
        # An empty class
        #
        #     class Derp; end
        #     s(:class, :Derp, nil)
        #
        # A trivial class
        #
        #     class Derp; puts; end
        #     s(:class, :Derp, nil, s(:call, nil, :puts))
        #
        # A TestCase
        #
        #     s(:class,
        #       :BananaTest,
        #       s(:colon2, s(:const, :ActiveSupport), :TestCase),
        #       s(:iter,
        #         s(:call, nil, :test, s(:str, "is delicious")),
        #         s(:args),
        #         s(:call, nil, :assert,
        #           s(:call, s(:call, s(:const, :Banana), :new), :delicious?)
        #         )
        #       )
        #     )
        #
        def process(exp)
          raise ArgumentError unless exp.shift == :class
          name = exp.shift
          parent = exp.shift
          iter = exp.empty? ? nil : exp.shift
          raise("Unexpected class expression") unless exp.empty?
          result(name, parent, iter)
        end

        private

        def active_support_test_case?(parent)
          parent.length == 3 &&
            parent[1] == s(:const, :ActiveSupport) &&
            parent[2] == :TestCase
        end

        def assert_symbol(obj)
          raise TypeError unless obj.is_a?(Symbol)
        end

        def assert_valid_rspec_iter(iter)
          raise(NotImplemented, "Empty test case") if iter.nil?
          raise ArgumentError unless iter.is_a?(Sexp)
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
            rspec_describe(name, iter)
          elsif iter.nil?
            s(:class, name, parent)
          else
            s(:class, name, parent, full_process(iter))
          end
        end

        # Returns a S-expression representing a call to RSpec.describe
        def rspec_describe(name, iter)
          assert_symbol(name)
          assert_valid_rspec_iter(iter)
          rspec = s(:const, :RSpec)
          arg = s(:const, described_class(name))
          describe = s(:call, rspec, :describe, arg)
          s(:iter, describe, s(:args), full_process(iter))
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
