# 
#  run.rb: stacatto descending
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Purr < Gesture
    
    ROOT_NOTE = 40
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      start_time = Gesture::next_beat(now, TICKS_8N)
      event_time = start_time
            
      duration = 50 # TICKS_2N
      velocity = 100 #rand 20 + 100
      # pitch = ROOT_NOTE + INTERVALS[rand INTERVALS.length]
      
      4.times do
        events << [event_time.ceil, ["note", ROOT_NOTE, 80, TICKS_64N]]
        
        event_time += TICKS_32N
      end
      
      # events << [event_time, "done"]
      
      return events, start_time
    end
    
  end
end
