module MinitestToRspec
  class Error < StandardError; end
  class ProcessingError < Error; end
  class NotImplemented < Error; end

  class ModuleShorthandError < NotImplemented
    def message
      <<-EOS
Unsupported class definition: Module shorthand (A::B::C) is not supported.
Please convert your class definition to use nested modules and try again.
      EOS
    end
  end
end
