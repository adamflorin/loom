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


# # INIT
# # 
#  TODO: wrap in method to get exception handling
# 
$repertoire_classname = ARGV.shift
$repertoire = MusicLoom.const_get($repertoire_classname).new


# # MAX MESSAGES
# #

# generates gesture if none is in the queue,
# AND outputs next event
# 
def next_event(now)
  $repertoire.next_event(now)
end

# Flush queue
# 
def clear_events
  $repertoire.clear_events
end


# wrap all Max messages in rescuable
# NOTE: must be updated whenever methods are added/deleted!
#
Object.init_rescuable [:next_event, :clear_events]


#
#
puts "Loaded music_loom_external.rb."

# tell patcher we're ready
# 
outlet 0, "ready"
