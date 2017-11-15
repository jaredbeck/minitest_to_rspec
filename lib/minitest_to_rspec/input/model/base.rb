# frozen_string_literal: true

require 'minitest_to_rspec/sexp_assertions'

module MinitestToRspec
  module Input
    module Model
      # Input models are simple data objects
      # representing the S-expressions they are named after.
      class Base
        include SexpAssertions
      end
    end
  end
end
