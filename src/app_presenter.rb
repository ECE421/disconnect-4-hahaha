require_relative 'game_board/cli_game_board_view'
require_relative 'game_board/game_board_presenter'
require_relative 'game_board/game_board_view'
require_relative 'game_over/cli_game_over_view'
require_relative 'game_over/game_over_presenter'
require_relative 'game_over/game_over_view'
require_relative 'main_menu/cli_main_menu_view'
require_relative 'main_menu/main_menu_presenter'
require_relative 'main_menu/main_menu_view'

# Presenter class for the AppModel
class AppPresenter
  def update(signal, *data)
    case signal
    when 'attach_model'
      attach_model(data[0])
    when 'init_views'
      init_views(data[0], data[1])
    when 'turn_updated'
      turn_updated(data[0])
    when 'game_phase_updated'
      game_phase_updated(data[0])
    when 'game_type_updated'
      game_type_updated(data[0])
    when 'game_mode_updated'
      game_mode_updated(data[0])
    else
      raise(ArgumentError)
    end
  end

  def attach_model(model)
    @model = model
  end

  def init_views(window, interface)
    @window = window

    if interface == AppModel::GUI
      @main_menu_view = MainMenuView.new(@window)

      @game_board_view = GameBoardView.new(@window)

      @game_over_view = GameOverView.new(@window)
    elsif interface == AppModel::CLI
      @main_menu_view = CLIMainMenuView.new

      @game_board_view = CLIGameBoardView.new

      @game_over_view = CLIGameOverView.new
    end

    @main_menu_presenter = MainMenuPresenter.new(@model)
    @main_menu_view.add_observer(@main_menu_presenter)

    @game_board_presenter = GameBoardPresenter.new(@model)
    @game_board_view.add_observer(@game_board_presenter)

    @game_over_presenter = GameOverPresenter.new(@model)
    @game_over_view.add_observer(@game_over_presenter)
  end

  def turn_updated(state)
    @game_board_view.draw(state)
  end

  def game_phase_updated(state)
    @window.each { |child| @window.remove(child) } if state[:interface] == AppModel::GUI

    if state[:phase] == AppModel::MENU
      @main_menu_view.draw(state[:type], state[:mode])
    elsif state[:phase] == AppModel::IN_PROGRESS
      @game_board_view.bind_layout
      @game_board_view.draw(state)
    elsif state[:phase] == AppModel::GAME_OVER
      @game_over_view.draw(state[:result])
    end
  end

  def game_type_updated(state)
    return unless state[:interface] == AppModel::GUI

    @window.each { |child| @window.remove(child) }
    @main_menu_view.draw(state[:type], state[:mode])
  end

  def game_mode_updated(state)
    return unless state[:interface] == AppModel::GUI

    @window.each { |child| @window.remove(child) }
    @main_menu_view.draw(state[:type], state[:mode])
  end
end
