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
  MusicLoom::Player.send(:include, behavior_class)
  puts "Loaded behavior #{behavior_class_name}."
end

# 
# 
def set_behavior_parameter(key, value)
  # puts "Setting #{key} -> #{value}"
  $player.set_player_option(key, value)
end

# load one motif
# 
def load_motif(device_id, motif_class_name)
  $player.add_motif(device_id, motif_class_name)
  puts "Loaded motif #{motif_class_name} on device #{device_id}"
end

def set_motif_weight(device_id, weight)
  # puts "Setting weight to #{weight} for motif on device #{device_id}"
  $player.get_motif(device_id).weight = weight
end

# remove motif
# 
def remove_motif(device_id)
  $player.remove_motif(device_id)
  puts "Removed motif on device #{device_id}"
end

# 
# 
def set_motif_parameter(device_id, key, value)
  # puts "Setting #{key} -> #{value} on device #{device_id}"
  $player.get_motif(device_id).parameters[key] = value
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
