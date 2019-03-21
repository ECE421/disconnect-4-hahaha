require 'observer'

# View that represents that playable game board
class GameBoardView
  include Observable

  def initialize(window)
    @window = window # Reference to the application window
  end

  def draw(board_data, turn)
    # Here we construct the container that is going pack our buttons
    grid = Gtk::Grid.new
    @window.add(grid)

    css_provider = Gtk::CssProvider.new
    css_provider.load(data: <<-CSS)
      button {
        background-image: image(blue);
      }

      button:hover {
        background-image: image(purple);
      }
    CSS

    (0..6).each do |col|
      (0..5).each do |row|
        button = Gtk::Button.new
        button.set_size_request(100, 100)
        button.style_context.add_provider(
          css_provider,
          Gtk::StyleProvider::PRIORITY_USER
        )
        button.signal_connect 'clicked' do |_|
          puts 'Hello World!!'
        end
        grid.attach(button, col, row, 1, 1)
      end
    end

    @window.show_all
  end

  def on_click(element)
    # notify_observers(element_data)
  end
end
