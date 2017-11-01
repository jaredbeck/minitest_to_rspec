module Helpers
  def parse(ruby)
    RubyParser.new.parse(ruby)
  end
end
