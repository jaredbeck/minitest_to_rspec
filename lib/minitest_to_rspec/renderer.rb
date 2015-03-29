require_relative "subrenderers/call"

module MinitestToRspec
  class Renderer < SexpProcessor
    def initialize(buffer)
      super()
      self.strict = false
      @buffer = buffer
    end

    def process_call(exp)
      Subrenderers::Call.process(exp, @buffer)
    end
  end
end
