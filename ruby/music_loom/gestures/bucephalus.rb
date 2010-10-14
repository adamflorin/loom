# 
#  bucephalus.rb: as in, the bouncing ball
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Bucephalus < Gesture
    
    LONG_DURATION = 480
    NUM_STEPS = 20
    
    # set up a note to play faster & faster
    # 
    def generate_events(now)
      events = []
      event_time = next_beat(now)
      
      # TODO: add a pitch bend continuous event here
      
      NUM_STEPS.times do |i|
        # > 0. and <= 1.0
        pcnt = (NUM_STEPS - (i+1)).to_f / NUM_STEPS
        
        # exponential for effect
        delta_ms = LONG_DURATION * (pcnt ** 2.0)
        
        # push onto the queue
        events << [event_time, ["note", 59.9, 100, 100]]
        
        event_time += delta_ms
      end
      
      return events
    end
    
  end
end
