require 'gtk3'

app = Gtk::Application.new('disconnect.four.hahaha', :flags_none)

app.signal_connect 'activate' do |application|
  window = Gtk::ApplicationWindow.new(application)
  window.set_title('Window')
  window.set_default_size(1000, 800)
  window.present
end

puts app.run([$PROGRAM_NAME] + ARGV)
