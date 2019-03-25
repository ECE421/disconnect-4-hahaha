require 'test/unit'
require_relative '../src/app_model'

class AppModelTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @model = AppModel.new(nil, nil)
  end

  def test_update_turn
    assert_equal(AppModel::PLAYER_1_TURN, @model.state[:turn])
    @model.update_turn(AppModel::PLAYER_2_TURN)
    assert_equal(AppModel::PLAYER_2_TURN, @model.state[:turn])
  end
end
