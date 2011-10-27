# 
#  bounce.rb: as in Bucephalus Bouncing Ball
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Bounce < Motif
    
    LONG_DURATION = TICKS_4N
    
    # set up a note to play faster & faster
    # 
    # TODO: input: timescale (for LONG_DURATION)
    # 
    def generate_gesture(now)
      Gesture.new(Motif::next_beat(now)) do |gesture|
        event_time = 0
        steps = @parameters[:steps].to_i
        
        steps.times do |i|
          # > 0. and <= 1.0
          pcnt = (steps - (i+1)).to_f / steps

          # exponential for effect
          delta_ms = LONG_DURATION * (pcnt ** 2.0)

          # EVENT
          gesture.make :note, :at => event_time, :data => {
            :pitch => @parameters[:pitch],
            :velocity => 100,
            :duration => delta_ms
          }

          # post-
          event_time += delta_ms
        end
      end
    end
    
  end
end
