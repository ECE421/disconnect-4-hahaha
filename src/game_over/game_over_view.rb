require 'observer'

# View that represents the game over screen
class GameOverView
  include Observable

  def draw(winner) end

  def on_click(element)
    # notify_observers(element_data)
  end
end
