# 
#  pump.rb: pump on 8ve
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Shapely < Gesture
    
    MORPHOLOGY = [0.8]
    PITCHES = [60, 72, 67, 70, 63]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now)
      events = []
      event_time = Gesture::next_beat(now)
      
      # morph.
      pitch_index = (MORPHOLOGY[0] * (PITCHES.size - 1)).ceil
      pitch = PITCHES[pitch_index] + 20
      
      velocity = 100
      
      dur = TICKS_8N
      
      events << [event_time, ["note", pitch, velocity, dur]]
      
      events << [event_time + TICKS_8N, ["done"]]
      
      return events
    end
    
  end
end
