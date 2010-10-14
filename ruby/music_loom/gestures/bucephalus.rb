# 
#  bucephalus.rb: as in, the bouncing ball
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Bucephalus < Gesture
    
    # set up a note to play faster & faster
    # 
    def generate_events(now)
      events = []
      
      start_time = (now / 480).ceil * 480
      event_time = start_time

      long_dur = 480
      steps = 20

      # TODO: add a pitch bend continuous event here

      steps.times do |i|
        # > 0. and <= 1.0
        pcnt = (steps - (i+1)).to_f / steps

        # exponential for effect
        delta_ms = long_dur * (pcnt ** 2.0)

        # push onto the queue
        events << [event_time, ["note", 59.9, 100, 100]]

        event_time += delta_ms
      end
      
      return events
    end
    
  end
end
