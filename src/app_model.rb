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
    if @state[:mode] == CPU_PLAYER
      update_turn(PLAYER_2_TURN) # start player as player 2
      cpu_turn # cpu makes a move
      update_turn(PLAYER_1_TURN) # gives turn back to player 1
    end
  end

  def back_to_main_menu
    @state[:turn] = PLAYER_1_TURN
    @state[:type] = CONNECT_4
    @state[:mode] = PLAYER_PLAYER
    @state[:board_data] = Array.new(6) { Array.new(7, 0) }
    @state[:result] = NO_RESULT_YET
    update_game_phase(MENU)
  end

  def update_game_phase(phase)
    @state[:phase] = phase
    @presenter.game_phase_updated(@state)
  end

  def place_token(column_index)
    token_played = board_place_token(column_index)

    result = game_result

    if result != NO_RESULT_YET
      @state[:result] = result
      update_game_phase(GAME_OVER)
    elsif @state[:turn] == PLAYER_1_TURN && token_played
      update_turn(PLAYER_2_TURN)
      if @state[:mode] == PLAYER_CPU
        cpu_turn # cpu makes a move
        update_turn(PLAYER_1_TURN) # gives turn back
      end
    elsif @state[:turn] == PLAYER_2_TURN && token_played
      update_turn(PLAYER_1_TURN)
      if @state[:mode] == CPU_PLAYER
        cpu_turn # cpu makes a move
        update_turn(PLAYER_2_TURN) # gives turn back
      end
    elsif !token_played
      update_turn(@state[:turn]) # Column was full, try again
    end
  end

  def board_place_token(column_index)
    Matrix[*@state[:board_data]].column(column_index).to_a.reverse.each_with_index do |element, reverse_index|
      next unless element.zero?

      row_index = (@state[:board_data].length - 1) - reverse_index
      @state[:board_data][row_index][column_index] = @state[:turn]
      return true
    end
    false
  end

  def board_remove_token(column_index)
    Matrix[*@state[:board_data]].column(column_index).to_a.reverse.each_with_index do |element, reverse_index|
      next unless element.zero?

      row_index = @state[:board_data].length - reverse_index
      @state[:board_data][row_index][column_index] = 0
    end
  end

  # our cpu algorithm works as follows
  # 1. attempt to place a token in each column as current player (aggresion)
  # if any token results in a win then make that placement
  # 2. attempt to place a token in each column as opposite player (prevention)
  # if any token results in a win then make that placement
  # 3. if neither condition place token in longest vertical or horizontal (extension)
  def cpu_turn
    cpu_progress unless cpu_attempt || cpu_prevent # ruby craziness
  end

  # cpu_attempt works to try to win the game by placing a token in each column once and checking to see if any result in a win condition. it clears all unsuccessfull token attempts
  def cpu_attempt
    (0..6).each do |c|
      token_placed = board_place_token(c)
      if game_result != NO_RESULT_YET # full send
        @state[:result] = game_result
        update_game_phase(GAME_OVER)
        return true
      elsif token_placed # make sure token was placed before force delete
        board_remove_token(c)
      end
    end
    false
  end

  # cpu_prevent works to try and stop the other player from winning the game by placing a token in each column once as the other player and checking to see if any result in a win condition, if so then it places a token there as the cpu to prevent the win. it clears all unsuccessfull token attempts
  def cpu_prevent
    current_turn = @state[:turn]
    @state[:turn] = current_turn == PLAYER_1_TURN ? PLAYER_2_TURN : PLAYER_1_TURN # pretend to be other player
    (0..6).each do |c|
      token_placed = board_place_token(c)
      if game_result != NO_RESULT_YET
        board_remove_token(c) # remove the winning move
        @state[:turn] = current_turn # change back
        board_place_token(c) # place token to block
        return true
      elsif token_placed # make sure token was placed before force delete
        board_remove_token(c)
      end
    end
    @state[:turn] = current_turn # remember to switch back
    false
  end

  # cpu_progress works to progress the cpu to victory. it iterates all possible moves going left to right until it finds one that results in a win, it then erases all previous moves and places this move.
  def cpu_progress
    remove_array = []
    next_move = nil
    (0..3).each do |_i|
      break if game_result != NO_RESULT_YET
      (0..6).each do |c|
        token_placed = board_place_token(c)
        remove_array.push(c) if token_placed # add move for later deletion
        if game_result != NO_RESULT_YET
          next_move = c
          break
        end
      end
    end
    remove_array.reverse_each do |c| # remove moves from our array 'stack'
      board_remove_token(c)
    end
    if next_move # if we found a winning move do it
      board_place_token(next_move)
    else # otherwise look for a valid random move
      move_made = false
      move_made = board_place_token(rand(0..6)) until move_made
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
    return @state[:turn] if connect_4_horizontal? || connect_4_vertical? || connect_4_diagonal?

    return TIE if connect_4_tie?

    NO_RESULT_YET
  end

  def toot_and_otto_game_result
    result = toot_and_otto_horizontal
    return result unless result == NO_RESULT_YET

    result = toot_and_otto_vertical
    return result unless result == NO_RESULT_YET

    result = toot_and_otto_left_diagonal
    return result unless result == NO_RESULT_YET

    toot_and_otto_right_diagonal
  end

  def connect_4_tie?
    @state[:board_data].each do |row|
      row.each do |element|
        return false if element.zero?
      end
    end
    true
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
    start_indices = [[2, 0], [1, 0], [0, 0], [0, 1], [0, 2], [0, 3]]
    start_indices.each do |index|
      left_diagonal = []
      i = index[0]
      j = index[1]

      until i == 6 || j == 7
        left_diagonal.push(@state[:board_data][i][j])
        i += 1
        j += 1
      end

      consecutive = 0
      left_diagonal.each do |element|
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

  def connect_4_right_diagonal?
    start_indices = [[0, 3], [0, 4], [0, 5], [0, 6], [1, 6], [2, 6]]
    start_indices.each do |index|
      right_diagonal = []
      i = index[0]
      j = index[1]

      until i == 6 || j == -1
        right_diagonal.push(@state[:board_data][i][j])
        i += 1
        j -= 1
      end

      consecutive = 0
      right_diagonal.each do |element|
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
    start_indices = [[2, 0], [1, 0], [0, 0], [0, 1], [0, 2], [0, 3]]
    start_indices.each do |index|
      left_diagonal = []
      i = index[0]
      j = index[1]

      until i == 6 || j == 7
        left_diagonal.push(@state[:board_data][i][j])
        i += 1
        j += 1
      end

      consecutive_toot = ''
      consecutive_otto = ''
      left_diagonal.each do |element|
        consecutive_toot, consecutive_otto = toot_and_otto_increment(consecutive_toot, consecutive_otto, element)
        return TIE if consecutive_toot == 'toot' && consecutive_otto == 'otto'
        return PLAYER_1_WINS if consecutive_toot == 'toot'
        return PLAYER_2_WINS if consecutive_otto == 'otto'
      end
    end
    NO_RESULT_YET
  end

  def toot_and_otto_right_diagonal
    start_indices = [[0, 3], [0, 4], [0, 5], [0, 6], [1, 6], [2, 6]]
    start_indices.each do |index|
      right_diagonal = []
      i = index[0]
      j = index[1]

      until i == 6 || j == -1
        right_diagonal.push(@state[:board_data][i][j])
        i += 1
        j -= 1
      end

      consecutive_toot = ''
      consecutive_otto = ''
      right_diagonal.each do |element|
        consecutive_toot, consecutive_otto = toot_and_otto_increment(consecutive_toot, consecutive_otto, element)
        return TIE if consecutive_toot == 'toot' && consecutive_otto == 'otto'
        return PLAYER_1_WINS if consecutive_toot == 'toot'
        return PLAYER_2_WINS if consecutive_otto == 'otto'
      end
    end
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
