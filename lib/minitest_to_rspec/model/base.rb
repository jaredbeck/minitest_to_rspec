require_relative "../sexp_assertions"

module MinitestToRspec
  module Model

    # Classes inheriting `Base` are simple data objects
    # representing the S-expressions they are named after.
    class Base
      include SexpAssertions
    end
  end
end
