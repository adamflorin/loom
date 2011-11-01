# 
#  music_loom_external.rb: Max external for JRuby to access MusicLoom
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 


require "tools/monkeypatch"
require "music_loom/music_loom"

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

# FIXME:REFACTOR: behavior-specific!
# 
# def impulse(velocity)
#   $player.set_velocity(velocity)
# end

#  
# 
def init_player
  $player = MusicLoom::Player.new
end

# 
# 
def load_behavior(behavior_class_name)
  behavior_class = MusicLoom::Behaviors.const_get(behavior_class_name.to_s.camelize)
  
  # FIXME: handle duplicate behaviors better
  if MusicLoom::Player.ancestors.include? behavior_class
    raise "Cannot include same behavior twice!"
  end
  
  # mix in
  MusicLoom::Player.send(:include, behavior_class)
  
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
  outlet 1, 'bang'
end

# INIT
# 

init_player

# FIXME: register w/ env. (getting weird error now)
# 
# register w/ environment
# $environment = get_global(:environment)
# $environment.register_player($player)

# Ready. Log & notify.
#
notify_loaded
puts "Loaded MusicLoom::Player."
