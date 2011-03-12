# 
#  bucephalus.rb: as in, the bouncing ball
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Bucephalus < Gesture
    
    ROOT_NOTE = 59
    LONG_DURATION = TICKS_4N
    NUM_STEPS = 20
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      start_time = Gesture::next_beat(now)
      event_time = start_time
      
      # TODO: add a pitch bend continuous event here
      
      NUM_STEPS.times do |i|
        # pre-
        # > 0. and <= 1.0
        pcnt = (NUM_STEPS - (i+1)).to_f / NUM_STEPS
        
        # exponential for effect
        delta_ms = LONG_DURATION * (pcnt ** 2.0)
        
        velocity = 100
        
        # EVENT
        events << [event_time, ["note", ROOT_NOTE, velocity, delta_ms]]
        
        # post-
        event_time += delta_ms
      end
      
      return events, start_time
    end
    
  end
end
