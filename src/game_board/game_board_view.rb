require 'observer'

# View that represents that playable game board
class GameBoardView
  include Observable

  def initialize(window)
    @window = window # Reference to the application window
    @css_provider = Gtk::CssProvider.new
    @css_provider.load(data: File.read('./src/game_board/game_board.css'))
  end

  def draw(board_data)
    grid = Gtk::Grid.new

    (0..6).each do |col|
      button = Gtk::Button.new
      button.set_size_request(100, 600)
      button.style_context.add_provider(@css_provider, Gtk::StyleProvider::PRIORITY_USER)
      button.signal_connect('clicked') do |_|
        changed
        notify_observers('column_clicked', col)
      end
      grid.attach(button, col, 0, 1, 1)
    end

    @window.add(grid)
    @window.show_all
  end
end
