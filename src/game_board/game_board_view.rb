require 'observer'

# View that represents the game board
class GameBoardView
  include Observable

  def initialize(window)
    @window = window # Reference to the application window

    @column_style = Gtk::CssProvider.new
    @column_style.load(data: 'button {background-image: image(grey); opacity: 0;} button:hover {opacity: 0.5;}')

    @empty_token_style = Gtk::CssProvider.new
    @empty_token_style.load(data: 'button {background-image: image(white);}')

    @token_1_style = Gtk::CssProvider.new
    @token_1_style.load(data: 'button {background-image: image(red);}')

    @token_2_style = Gtk::CssProvider.new
    @token_2_style.load(data: 'button {background-image: image(yellow);}')

    @cells = Array.new(6) { Array.new(7, nil) }
    @layout = Gtk::Fixed.new

    cell_grid = Gtk::Grid.new
    @layout.put(cell_grid, 0, 0)

    (0..6).each do |col|
      (0..5).each do |row|
        cell = Gtk::Button.new
        cell.set_size_request(100, 100)
        @cells[row][col] = cell
        cell_grid.attach(cell, col, row, 1, 1)
      end
    end

    column_grid = Gtk::Grid.new
    @layout.put(column_grid, 0, 0)

    (0..6).each do |column_index|
      column = Gtk::Button.new
      column.set_size_request(100, 600)
      column.style_context.add_provider(@column_style, Gtk::StyleProvider::PRIORITY_USER)
      column.signal_connect('clicked') do |_|
        changed
        notify_observers('column_clicked', column_index)
      end
      column_grid.attach(column, column_index, 0, 1, 1)
    end
  end

  def bind_layout
    @window.add(@layout)
  end

  def draw(board_data)
    (0..6).each do |col|
      (0..5).each do |row|
        if (board_data[row][col]).zero?
          @cells[row][col].style_context.add_provider(@empty_token_style, Gtk::StyleProvider::PRIORITY_USER)
        elsif board_data[row][col] == 1
          @cells[row][col].style_context.add_provider(@token_1_style, Gtk::StyleProvider::PRIORITY_USER)
        elsif board_data[row][col] == 2
          @cells[row][col].style_context.add_provider(@token_2_style, Gtk::StyleProvider::PRIORITY_USER)
        end
      end
    end

    @window.show_all
  end
end
