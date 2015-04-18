require 'test_helper'

class BananasControllerTest < ActionController::TestCase
  include BananaSeeds

  setup do
    scare_away_monkeys
  end

  test 'index' do
    get :index
    assert_response :success
  end
end
