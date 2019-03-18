require 'observer'

# View that represents that playable game board
class GameBoardView
  include Observable

  def draw(board_data, turn) end

  def on_click(element)
    # notify_observers(element_data)
  end
end
