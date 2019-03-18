require 'gtk3'
require_relative 'app_presenter'

# Main model that holds the data, state, and business logic of the app
class AppModel
  attr_reader(:app)

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
    @app = Gtk::Application.new('disconnect.four.hahaha', :flags_none)

    @app.signal_connect 'activate' do |application|
      window = Gtk::ApplicationWindow.new(application)
      window.set_title('Window')
      window.set_border_width(20)

      # Here we construct the container that is going pack our buttons
      grid = Gtk::Grid.new
      window.add(grid)

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

      window.show_all
    end

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
