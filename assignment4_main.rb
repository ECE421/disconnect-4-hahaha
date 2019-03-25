require 'gtk3'
require_relative 'src/app_model'
require_relative 'src/app_presenter'

app = Gtk::Application.new('disconnect.four.hahaha', :flags_none)
model = AppModel.new(app, AppPresenter.new)
puts(model.app.run([$PROGRAM_NAME] + ARGV))
