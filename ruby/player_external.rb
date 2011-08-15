# 
#  music_loom_external.rb: Max external for JRuby to access MusicLoom
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 


require "tools/monkeypatch"
require "music_loom/music_loom"


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

def impulse(velocity)
  $player.set_velocity(velocity)
end

# for patcher control of motif morphological params
# 
def set_motif_option(key, value)
  $player.set_motif_option(key, value)
end

# for patcher control of motif morphological params
# 
def set_player_option(key, value)
  $player.set_player_option(key, value)
end

# INIT
# 

# build player
$player_classname = ARGV.shift
$player = MusicLoom.const_get($player_classname).new

# register w/ environment
$environment = get_global(:environment)
$environment.register_player($player)


# Ready. Log & notify.
#
puts "Loaded MusicLoom::#{$player_classname}."
outlet 0, "ready"
