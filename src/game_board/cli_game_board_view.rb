require 'observer'
require 'readline'

# A plain text version of the game board to be displayed in stdout
class CLIGameBoardView
  include(Observable)

  def initialize
    @rows = [
      '_ _ _ _ _ _ _ ',
      '_ _ _ _ _ _ _ ',
      '_ _ _ _ _ _ _ ',
      '_ _ _ _ _ _ _ ',
      '_ _ _ _ _ _ _ ',
      '_ _ _ _ _ _ _ '
    ]
  end

  def bind_layout; end

  def draw(state)
    (0..6).each do |col|
      (0..5).each do |row|
        if (state[:board_data][row][col]).zero?
          @rows[row][col * 2] = '_'
        elsif state[:board_data][row][col] == 1 && state[:type] == AppModel::CONNECT_4
          @rows[row][col * 2] = 'R'
        elsif state[:board_data][row][col] == 1 && state[:type] == AppModel::TOOT_AND_OTTO
          @rows[row][col * 2] = 'T'
        elsif state[:board_data][row][col] == 2 && state[:type] == AppModel::CONNECT_4
          @rows[row][col * 2] = 'Y'
        elsif state[:board_data][row][col] == 2 && state[:type] == AppModel::TOOT_AND_OTTO
          @rows[row][col * 2] = 'O'
        end
      end
    end

    puts('')
    puts('1 2 3 4 5 6 7')
    @rows.each { |row| puts(row) }

    return unless state[:player_turn]

    column_index = 0
    valid_input = false
    until valid_input
      input = Readline.readline("Player #{state[:turn]}:", true)
      if /([1-7])/.match?(input)
        valid_input = true
        column_index = Integer(/([1-7])/.match(input)[0]) - 1
      else
        puts('Invalid command. Must input column number as: <integer> (1-7)')
      end
    end

    changed
    notify_observers('column_clicked', column_index)
  end
end
