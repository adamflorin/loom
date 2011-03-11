# 
#  flipper.rb: just flip on whole step in changing rhythm
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Hold < Gesture
    
    ROOT_NOTE = 60
    INTERVALS = [0, 2, -1]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      event_time = Gesture::next_beat(now) #, TICKS_8N)
      
      double_it = (rand 2).zero?
            
      duration = TICKS_2N
      velocity = 100 #rand 20 + 100
      pitch = ROOT_NOTE + INTERVALS[rand INTERVALS.length]
      
      events << [event_time, ["note", pitch, velocity, double_it ? TICKS_8N : TICKS_2N]]
      
      if double_it
        events << [event_time + TICKS_8N, ["note", pitch, velocity, TICKS_2N]]
      end
      
      events << [event_time + (double_it ? TICKS_8N : 0) + TICKS_2N, "done"]
      
      return events
    end
    
  end
end
