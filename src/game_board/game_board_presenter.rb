# A presenter that converts actions in the GameBoardView to AppModel function calls
class GameBoardPresenter
  def initialize(model)
    @model = model
  end

  def update(signal, *data)
    if signal == 'column_clicked'
      column_index = data[0]
      puts(column_index)
    end
  end
end
