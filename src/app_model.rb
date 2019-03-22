require 'gtk3'
require 'matrix'
require_relative 'app_presenter'

# Main model that holds the data, state, and business logic of the app
class AppModel
  attr_reader(:app)

  # Player turns
  PLAYER_1_TURN = 1
  PLAYER_2_TURN = 2

  # Game types
  CONNECT_4 = 0
  TOOT_AND_OTTO = 1

  # Game modes
  PLAYER_PLAYER = 0
  PLAYER_CPU = 1
  CPU_PLAYER = 2
  CPU_CPU = 3

  # Game phases
  MENU = 0
  IN_PROGRESS = 1
  GAME_OVER = 2

  # GAME_RESULT
  NO_RESULT_YET = 0
  PLAYER_1_WINS = 1
  PLAYER_2_WINS = 2
  TIE = 3

  def initialize
    @app = Gtk::Application.new('disconnect.four.hahaha', :flags_none)

    @app.signal_connect('activate') do |application|
      window = Gtk::ApplicationWindow.new(application)
      window.set_title('Ruby Connect Games')
      window.set_size_request(400, 400)
      window.set_border_width(20)

      @presenter = AppPresenter.new(self, window)

      # Initial game state
      @state = {
        turn: PLAYER_1_TURN,
        type: CONNECT_4,
        mode: PLAYER_PLAYER,
        phase: MENU,
        board_data: Array.new(6) { Array.new(7, 0) },
        result: NO_RESULT_YET
      }

      @presenter.game_phase_updated(@state) # Start the game at the main menu
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
    token_played = false
    Matrix[*@state[:board_data]].column(column_index).to_a.reverse.each_with_index do |element, reverse_index|
      next unless element.zero?

      row_index = (@state[:board_data].length - 1) - reverse_index
      @state[:board_data][row_index][column_index] = @state[:turn]
      token_played = true
      break
    end

    result = game_result

    if result != NO_RESULT_YET
      @state[:result] = result
      update_game_phase(GAME_OVER)
    elsif @state[:turn] == PLAYER_1_TURN && token_played
      update_turn(PLAYER_2_TURN)
    elsif @state[:turn] == PLAYER_2_TURN && token_played
      update_turn(PLAYER_1_TURN)
    elsif !token_played
      update_turn(@state[:turn]) # Column was full, try again
    end
  end

  def game_result
    if @state[:type] == CONNECT_4
      connect_4_game_result
    elsif @state[:type] == TOOT_AND_OTTO
      toot_and_otto_game_result
    end
  end

  def connect_4_game_result
    @state[:turn] if connect_4_horizontal? || connect_4_vertical? || connect_4_diagonal?
    TIE if connect_4_tie?
    NO_RESULT_YET
  end

  def toot_and_otto_game_result
    result = toot_and_otto_horizontal
    result unless result == NO_RESULT_YET

    result = toot_and_otto_vertical
    result unless result == NO_RESULT_YET

    result = toot_and_otto_left_diagonal
    result unless result == NO_RESULT_YET

    toot_and_otto_right_diagonal
  end

  def connect_4_tie?
    false
  end

  def connect_4_horizontal?
    @state[:board_data].each do |row|
      consecutive = 0
      row.each do |element|
        if element != @state[:turn]
          consecutive = 0
          next
        end

        consecutive += 1
        return true if consecutive == 4
      end
    end
    false
  end

  def connect_4_vertical?
    Matrix[*@state[:board_data]].column_vectors.each do |column|
      consecutive = 0
      column.each do |element|
        if element != @state[:turn]
          consecutive = 0
          next
        end

        consecutive += 1
        return true if consecutive == 4
      end
    end
    false
  end

  def connect_4_diagonal?
    connect_4_left_diagonal? || connect_4_right_diagonal?
  end

  def connect_4_left_diagonal?
    false
  end

  def connect_4_right_diagonal?
    false
  end

  def toot_and_otto_horizontal
    @state[:board_data].each do |row|
      consecutive_toot = ''
      consecutive_otto = ''
      row.each do |element|
        consecutive_toot, consecutive_otto = toot_and_otto_increment(consecutive_toot, consecutive_otto, element)
        return TIE if consecutive_toot == 'toot' && consecutive_otto == 'otto'
        return PLAYER_1_WINS if consecutive_toot == 'toot'
        return PLAYER_2_WINS if consecutive_otto == 'otto'
      end
    end
    NO_RESULT_YET
  end

  def toot_and_otto_vertical
    Matrix[*@state[:board_data]].column_vectors.each do |column|
      consecutive_toot = ''
      consecutive_otto = ''
      column.each do |element|
        consecutive_toot, consecutive_otto = toot_and_otto_increment(consecutive_toot, consecutive_otto, element)
        return TIE if consecutive_toot == 'toot' && consecutive_otto == 'otto'
        return PLAYER_1_WINS if consecutive_toot == 'toot'
        return PLAYER_2_WINS if consecutive_otto == 'otto'
      end
    end
    NO_RESULT_YET
  end

  def toot_and_otto_left_diagonal
    NO_RESULT_YET
  end

  def toot_and_otto_right_diagonal
    NO_RESULT_YET
  end

  def toot_and_otto_increment(consecutive_toot, consecutive_otto, element)
    return ['', ''] if element.zero?

    if element == 1
      if %W[#{+''} too].include?(consecutive_toot)
        consecutive_toot += 't'
      else
        consecutive_toot = ''
      end

      if %w[o ot].include?(consecutive_otto)
        consecutive_otto += 't'
      else
        consecutive_otto = ''
      end
    elsif element == 2
      if %w[t to].include?(consecutive_toot)
        consecutive_toot += 'o'
      else
        consecutive_toot = ''
      end

      if %W[#{+''} ott].include?(consecutive_otto)
        consecutive_otto += 'o'
      else
        consecutive_otto = ''
      end
    end

    [consecutive_toot, consecutive_otto]
  end
end
