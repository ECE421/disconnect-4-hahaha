require_relative 'game_board/game_board_presenter'
require_relative 'game_board/game_board_view'
require_relative 'game_over/game_over_presenter'
require_relative 'game_over/game_over_view'
require_relative 'main_menu/main_menu_presenter'
require_relative 'main_menu/main_menu_view'

# Presenter class for the AppModel
class AppPresenter
  def update(signal, data)
    if signal == 'attach_model'
      attach_model(data)
    elsif signal == 'init_views'
      init_views(data)
    elsif signal == 'turn_updated'
      turn_updated(data)
    elsif signal == 'game_phase_updated'
      game_phase_updated(data)
    end
  end

  def attach_model(model)
    puts('attach_model', model)
    @model = model
  end

  def init_views(window)
    @window = window

    @main_menu_view = MainMenuView.new(@window)
    @main_menu_presenter = MainMenuPresenter.new(@model)
    @main_menu_view.add_observer(@main_menu_presenter)

    @game_board_view = GameBoardView.new(@window)
    @game_board_presenter = GameBoardPresenter.new(@model)
    @game_board_view.add_observer(@game_board_presenter)

    @game_over_view = GameOverView.new(@window)
    @game_over_presenter = GameOverPresenter.new(@model)
    @game_over_view.add_observer(@game_over_presenter)
  end

  def turn_updated(state)
    @game_board_view.draw(state[:board_data], state[:type])
  end

  def game_phase_updated(state)
    @window.each { |child| @window.remove(child) }
    if state[:phase] == AppModel::MENU
      @main_menu_view.draw(state[:type], state[:mode])
    elsif state[:phase] == AppModel::IN_PROGRESS
      @game_board_view.bind_layout
      @game_board_view.draw(state[:board_data], state[:type])
    elsif state[:phase] == AppModel::GAME_OVER
      @game_over_view.draw(state[:result])
    end
  end
end
