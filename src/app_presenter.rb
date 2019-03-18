# Presenter class for the AppModel
class AppPresenter
  def initialize(model)
    @main_menu_view = MainMenuView.new
    @main_menu_presenter = MainMenuPresenter.new(model, @main_menu_view)

    @game_board_view = GameBoardView.new
    @game_board_presenter = GameBoardPresenter(model, @game_board_view)

    @game_over_view = GameOverView.new
    @game_over_presenter = GameOverPresenter(model, @game_over_view)
  end

  def turn_updated(state)
    @game_board_view.draw(state[:board_data], state[:turn])
  end

  def game_phase_updated(state)
    if state[:game_phase] == AppModel::MENU
      @main_menu_view.draw
    elsif state[:game_phase] == AppModel::IN_PROGRESS
      @game_board_view.draw(state[:board_data], state[:turn])
    elsif state[:game_phase] == AppModel::GAME_OVER
      @game_over_view.draw(state[:winner])
    end
  end
end
