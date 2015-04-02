module MinitestToRspec
  module Subprocessors
    class Base
      class << self

        # Run `exp` through a new `Processor`.  This is useful for expressions
        # that cannot be fully understood by a single subprocessor.  For
        # example, we process :iter expressions, because we're interested in
        # :iter that contain e.g. an `assert_difference`.  However, if the :iter
        # turns out to be uninteresting, we still want to fully process its
        # sub-expressions. TODO: `full_process` may not be the best name.
        def full_process(exp)
          Processor.new.process(exp)
        end

        def matcher(name, *args)
          exp = s(:call, nil, name)
          exp.concat(args)
        end
      end
    end
  end
end
