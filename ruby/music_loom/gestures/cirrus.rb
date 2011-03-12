# 
#  cirrus.rb: high-up cloud, curving subtlely downward
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Cirrus < Gesture
    
    ROOT_NOTE = 72
    PATTERN = [TICKS_8N, TICKS_16N, TICKS_16N]
    DESCENDING_NOTES = [0, -1, -1, -3, -3, -7, -10, -11]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      start_time = Gesture::next_beat(now)
      event_time = start_time
      
      accent = true
      pitch = ROOT_NOTE
      desc_by = 0
      
      PATTERN.each do |dur|
        # pre-
        velocity = accent ? 100 : 20
        pitch = ROOT_NOTE + DESCENDING_NOTES[desc_by]
        
        # EVENT
        events << [event_time, ["note", pitch, velocity, dur]]
        
        # post-
        accent = false
        event_time += dur
        desc_by += rand 3
      end
      
      return events, start_time
    end
    
  end
end
