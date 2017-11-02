# frozen_string_literal: true

module MinitestToRspec
  class Error < StandardError; end
  class ProcessingError < Error; end

  # Raise `UnknownVariant` to indicate that an expression is
  # not recognized.  This exception should always be rescued,
  # and the original expression should be used in the output.
  class UnknownVariant < Error; end

  # Raise `NotImplemented` to indicate that an expression is
  # recognized (not an `UnknownVariant`) but that `minitest_to_rspec`
  # does not (yet) implement a conversion.
  class NotImplemented < Error; end

  class ModuleShorthandError < NotImplemented
    DEFAULT_MESSAGE = <<~EOS
      Unsupported class definition: Module shorthand (A::B::C) is not supported.
      Please convert your class definition to use nested modules and try again.
    EOS

    def initialize(msg = nil)
      super(msg || DEFAULT_MESSAGE)
    end
  end
end
