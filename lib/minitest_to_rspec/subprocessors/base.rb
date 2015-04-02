module MinitestToRspec
  module Subprocessors
    class Base
      class << self

        # Run `exp` through a new `Processor`.  This is appropriate
        # for expressions like `:iter` (a block) which we're not
        # interested in processing.  We *are* interested in
        # processing expressions within an `:iter`, but not the
        # iter itself.  TODO: `full_process` may not be the best name.
        def full_process(exp)
          Processor.new.process(exp)
        end
      end
    end
  end
end
