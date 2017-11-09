require("rails_helper")
RSpec.describe(MyController, :type => :controller) do
  it("herp") { nil }
  it("derp") { nil }
  def do_not_convert_me
    # do nothing
  end
end
