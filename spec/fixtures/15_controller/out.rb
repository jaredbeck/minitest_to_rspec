require "rails_helper"
RSpec.describe BananasController, type: :controller do
  include BananaSeeds
  before { scare_away_monkeys }
  it "index" do
    get :index
    assert_response(:success)
  end
end
