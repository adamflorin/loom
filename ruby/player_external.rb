# 
#  loom_external.rb: Max external for JRuby to access Loom
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 


require "loom"

# help messages
# 
inlet_assist('check in (bang)')
outlet_assist('event out (list)', 'reloaded (bang)')

# check in: output an event from the queue, generate events, or
# do nothing but schedule a future check-in
# 
def check_in(now)
  
  # because float precision triggers TIMER FAILs
  now = now.ceil
  
  # takin it from the top
  $player.clear_events if (now <= 0)
  
  # check in, returning _some_ kind of an event
  outlet 0, $player.check_in(now)
end

# 
# 
def load_behavior(behavior_class_name)
  behavior_class = Loom::Player.const_get(behavior_class_name.to_s.camelize)
  
  if Loom::Player::Player.ancestors.include? behavior_class
    outlet 1, 'error'
    error "Cannot include same behavior twice!"
    return
  end
  
  # mix in
  Loom::Player::Player.send(:include, behavior_class)
  
  puts "Loaded behavior #{behavior_class_name.to_s.camelize}."
end

# 
# 
def set_behavior_parameter(key, *parameter)
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
