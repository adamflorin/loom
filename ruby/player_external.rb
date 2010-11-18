# 
#  music_loom_external.rb: Max external for mxj/ajm.ruby to access MusicLoom
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 


# relative to ruby.loadpaths in ajm.ruby.properties.
# For some reason, Ruby doesn't know the path of this external file.
# 
require "tools/monkeypatch"
require "tools/rescuable"
require "music_loom/music_loom"


# check in: output an event from the queue, generate events, or
# do nothing but schedule a future check-in
# 
def check_in(now)
  # takin it from the top
  $player.clear_events if (now <= 0)
  
  # check in, returning _some_ kind of an event
  $player.check_in(now)
end


# INIT
# 
rescuable do
  # build Repretoire
  $player_classname = ARGV.shift
  $player = MusicLoom.const_get($player_classname).new
  
  # register w/ atmosphere
  get_global(:atmosphere).register_player($player)
  
  # wrap all Max messages in rescuable
  # NOTE: must be updated whenever methods are added/deleted!
  Object.init_rescuable [:check_in]
end


# Ready. Log & notify.
#
puts "Loaded MusicLoom::#{$player_classname}."
outlet 0, "ready"
