require 'gtk3'
require 'matrix'
require_relative 'app_presenter'

# Main model that holds the data, state, and business logic of the app
class AppModel
  attr_reader(:app)

  # Player turns
  PLAYER_1 = 1
  PLAYER_2 = 2

  # Game types
  CONNECT_4 = 0
  OTTO_TOOT = 1

  # Game modes
  PLAYER_PLAYER = 0
  PLAYER_CPU = 1
  CPU_PLAYER = 2
  CPU_CPU = 3

  # Game phases
  MENU = 0
  IN_PROGRESS = 1
  GAME_OVER = 2

  def initialize
    @app = Gtk::Application.new('disconnect.four.hahaha', :flags_none)

    @app.signal_connect('activate') do |application|
      window = Gtk::ApplicationWindow.new(application)
      window.set_title('Ruby Connect Games')
      window.set_size_request(400, 400)
      window.set_border_width(20)

      @presenter = AppPresenter.new(self, window)

      @state = {
        turn: PLAYER_1,
        type: CONNECT_4,
        mode: PLAYER_PLAYER,
        phase: MENU,
        board_data: Array.new(6) { Array.new(7, 0) },
        winner: nil
      }

      @presenter.game_phase_updated(@state)
    end
  end

  def update_turn(turn)
    @state[:turn] = turn
    @presenter.turn_updated(@state)
  end

  def update_game_type(type)
    @state[:type] = type
  end

  def update_game_mode(mode)
    @state[:mode] = mode
  end

  def start_game
    update_game_phase(IN_PROGRESS)
  end

  def update_game_phase(phase)
    @state[:phase] = phase
    @presenter.game_phase_updated(@state)
  end

  def place_token(column_index)
    Matrix[*@state[:board_data]].column(column_index).to_a.reverse.each_with_index do |element, reverse_index|
      next unless element.zero?

      row_index = (@state[:board_data].length - 1) - reverse_index
      @state[:board_data][row_index][column_index] = @state[:turn]
      break
    end

    if game_won?
      update_game_phase(GAME_OVER)
    elsif @state[:turn] == PLAYER_1
      update_turn(PLAYER_2)
    elsif @state[:turn] == PLAYER_2
      update_turn(PLAYER_1)
    end
  end

  def game_won?
    false
  end
end
