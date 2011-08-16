# 
#  pump.rb: pump on 8ve
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Shapely < Motif
    
    MORPHOLOGY = [0.8]
    PITCHES = [60, 72, 67, 70, 63]
    
    # set up a note to play faster & faster
    # 
    def generate_gesture(now, player_options = {})
      events = []
      start_time = Motif::next_beat(now)
      event_time = start_time
      
      # morph.
      pitch_index = (MORPHOLOGY[0] * (PITCHES.size - 1)).ceil
      pitch = PITCHES[pitch_index] + 20
      
      velocity = 100
      
      dur = TICKS_8N
      
      events << [event_time, ["note", pitch, velocity, dur]]
      
      events << [event_time + TICKS_8N, ["done"]]
      
      return events, start_time
    end
    
  end
end
