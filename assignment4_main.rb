require_relative 'src/app_model'

model = AppModel.new
puts(model.app.run([$PROGRAM_NAME] + ARGV))
