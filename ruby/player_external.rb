# 
#  loom_external.rb: Max external for JRuby to access Loom
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 


require "loom"

# help messages
# 
inlet_assist('check in (bang)')
outlet_assist('event out (list)', 'status (loaded, error)')

# check in: output an event from the queue, generate events, or
# do nothing but schedule a future check-in
# 
def check_in(now)
  outlet 0, $player.check_in(now)
end

# 
# 
def load_module(module_name)
  $player.load_module(module_name)
  puts "Loaded module #{module_name.to_s.camelize}."
rescue Exception => e
  outlet 1, 'error'
  error e.message
end

# it's typically a generator, but not always!
# 
def set_parameter(key, *parameter)
  # puts "Setting #{key} -> #{parameter}"
  $player.set_generator_parameter(key, parameter)
end

# 
# 
def notify_loaded
  outlet 1, 'loaded'
end

# INIT
# 

$player = Loom::Player::Player.new

# Ready. Log & notify.
#
notify_loaded
puts "Loaded Loom::Player."
