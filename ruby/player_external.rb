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

# FIXME:REFACTOR: disabled for now!
# 
# # for patcher control of motif morphological params
# # 
# def set_motif_option(key, value)
#   $player.set_motif_option(key, value)
# end
# 
# # for patcher control of motif morphological params
# # 
# def set_player_option(key, value)
#   $player.set_player_option(key, value)
# end

# # TODO: LOAD & UNLOAD behaviors!
# # 
# def load_behavior(filename)
#   class_name = filename.match(/(.*)\.rb/)[1].capitalize
#   $player_class.send(:include, MusicLoom::Behaviors.const_get(class_name))
#   puts "Loaded behavior #{class_name}."
# end

# NOTE that we CLONE the Player class first, so that we can add behaviors
# to it and still be able to revert to behavior-less state later.
# 
def reload_player
  $player_class = MusicLoom::Player.clone
  $player = $player_class.new
end

# load one motif
# 
def load_motif(device_id, motif_class_name, weight)
  motif_class = MusicLoom.const_get(motif_class_name.to_s.camelize)
  $player.motifs << {
    :class => motif_class,
    :device_id => device_id,
    :weight => weight,
    :parameters => {}}
  
  puts "Loaded motif #{motif_class_name} on device #{device_id}"
end

# remove motif
# 
def remove_motif(device_id)
  $player.motifs.delete_if do |motif|
    motif[:device_id] == device_id
  end
  
  puts "Removed motif on device #{device_id}"
end

def set_motif_parameter(device_id, parameter_key, parameter_value)
  # puts "Setting #{parameter_key} -> #{parameter_value} on device #{device_id}"
  
  $player.motifs.select do |motif|
    motif[:device_id] == device_id
  end.first[:parameters][parameter_key] = parameter_value
end

def notify_loaded
  outlet 1, 'bang'
end

# INIT
# 

reload_player

# register w/ environment
$environment = get_global(:environment)
# FIXME: register w/ env. (getting weird error now)
# $environment.register_player($player)


# Ready. Log & notify.
#
puts "Loaded MusicLoom::Player."
notify_loaded
