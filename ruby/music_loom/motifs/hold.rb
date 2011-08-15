# 
#  flipper.rb: just flip on whole step in changing rhythm
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Hold < Motif
    
    ROOT_NOTE = 60
    INTERVALS = [0, 2, -1]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      start_time = Motif::next_beat(now).ceil #, TICKS_8N)
      event_time = start_time
      
      double_it = (rand 2).zero?
            
      duration = TICKS_2N
      velocity = 100 #rand 20 + 100
      pitch = ROOT_NOTE + INTERVALS[rand INTERVALS.length]
      
      events << [event_time.ceil, ["note", pitch, velocity, double_it ? TICKS_8N : TICKS_2N]]
      
      if double_it
        events << [event_time.ceil + TICKS_8N, ["note", pitch, velocity, TICKS_2N]]
      end
      
      events << [event_time.ceil + (double_it ? TICKS_8N : 0) + TICKS_2N, "done"]
      
      return events, start_time
    end
    
  end
end
