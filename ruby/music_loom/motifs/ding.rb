# 
#  ding.rb: the most dead simple motif possible:
#  just cue up one quarter note on middle C
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Ding < Motif
    
    ROOT_NOTE = 60
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      start_time = Motif::next_beat(now).ceil
      event_time = start_time
      
      duration = TICKS_4N
      velocity = 100
      pitch = ROOT_NOTE
      
      # note event
      events << [event_time.ceil, ["note", pitch, velocity, duration]]
      
      # "done" event
      events << [event_time.ceil + duration, "done"]
      
      return events, start_time
    end
    
  end
end
