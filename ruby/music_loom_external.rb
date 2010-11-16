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


# generate 1 gesture (= series of events)
# 
def generate_gesture(now)
  # puts "rec'd call to generate_gesture (now: #{now})"
  $repertoire.generate_gesture(now)
end

# outputs next event
# 
def next_event(now)
  # puts "event req'd"
  $repertoire.next_event
end

# Flush queue
# 
def clear_events
  $repertoire.clear_events
end


# INIT
# 
rescuable do
  # build Repretoire
  $repertoire_classname = ARGV.shift
  $repertoire = MusicLoom.const_get($repertoire_classname).new
  
  # wrap all Max messages in rescuable
  # NOTE: must be updated whenever methods are added/deleted!
  Object.init_rescuable [:next_event, :clear_events]
end


# Ready. Log & notify.
#
puts "Loaded MusicLoom::#{$repertoire_classname}."
outlet 0, "ready"
