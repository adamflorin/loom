# 
#  bucephalus.rb: as in, the bouncing ball
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Bucephalus < Motif
    
    ROOT_NOTE = 59
    LONG_DURATION = TICKS_4N
    NUM_STEPS = 20
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      Gesture.new(now) do |gesture|
        
        event_time = 0

        NUM_STEPS.times do |i|
          # pre-
          # > 0. and <= 1.0
          pcnt = (NUM_STEPS - (i+1)).to_f / NUM_STEPS

          # exponential for effect
          delta_ms = LONG_DURATION * (pcnt ** 2.0)

          velocity = 100

          # EVENT
          gesture.make :note, :at => event_time, :data => {
            :pitch => ROOT_NOTE, :velocity => velocity, :duration => delta_ms
          }

          # post-
          event_time += delta_ms
        end
      end
    end
    
  end
end
