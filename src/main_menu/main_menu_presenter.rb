# A presenter that converts actions in the MainMenuView to AppModel function calls
class MainMenuPresenter
  def initialize(model)
    @model = model
  end

  def update(signal, data)
    if signal == 'game_type_changed'
      @model.update_game_type(data[:type])
    elsif signal == 'game_mode_changed'
      @model.update_game_mode(data[:mode])
    elsif signal == 'start_game_clicked'
      @model.start_game
    else
      raise ArgumentError
    end
  end
end
