# 
#  cirrus.rb: high-up cloud, curving subtlely downward
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Cirrus < Gesture
    
    ROOT_NOTE = 72
    PATTERN = [TICKS_8N, TICKS_16N, TICKS_16N]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now)
      events = []
      event_time = next_beat(now)
      
      accent = true
      pitch = ROOT_NOTE
      
      PATTERN.each do |dur|
        # pre-
        velocity = accent ? 100 : 20
        
        # EVENT
        events << [event_time, ["note", pitch, velocity, dur]]
        
        # post-
        accent = false
        event_time += dur
        pitch -= rand 3
      end
      
      return events
    end
    
  end
end
