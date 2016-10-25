require './user_interface.rb'

user_interface = UserInterface.new
loop do
  user_interface.show_start_menu
  user_interface.process_selection
end
