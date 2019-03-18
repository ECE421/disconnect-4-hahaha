require 'observer'

# View that represents the main menu screen
class MainMenuView
  include Observable

  def draw; end

  def on_click(element)
    # notify_observers(element_data)
  end
end
