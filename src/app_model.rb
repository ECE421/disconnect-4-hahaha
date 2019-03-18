# Main model that holds the data, state, and business logic of the app
class AppModel
  # Player turns
  PLAYER_1 = 0
  PLAYER_2 = 1

  # Game types
  CONNECT_4 = 0
  OTTO_TOOT = 1

  # Game phases
  MENU = 0
  IN_PROGRESS = 1
  GAME_OVER = 2

  def initialize
    @presenter = AppPresenter.new(self)

    @state = {
      turn: PLAYER_1,
      game_type: CONNECT_4,
      game_phase: MENU,
      board_data: [],
      winner: nil
    }

    game_phase_updated
  end

  def update_turn(turn)
    @state[:turn] = turn
    turn_updated
  end

  def turn_updated
    @presenter.turn_updated(@state)
  end

  def update_game_phase(phase)
    @state[:phase] = phase
    game_phase_updated
  end

  def game_phase_updated
    @presenter.game_phase_updated(@state)
  end
end
