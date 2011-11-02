# 
#  timing.rb: rhythm/scheduling helpers
#  
#  Copyright November 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Tools
    module Timing
      
      # tick values
      TICKS_1N = 1920
      TICKS_2N = 960
      TICKS_4N = 480
      TICKS_8N = 240
      TICKS_16N = 120
      TICKS_32N = 60
      TICKS_64N = 30
      
      # return time of next downbeat (in ticks)
      # 
      def next_beat(now, divis = TICKS_4N)
        nb = (now.to_f / divis).ceil * divis

        # if time is really tight (i.e., generate_gesture event came in _right on_ a beat)
        # then just skip to next beat rather than letting it fail.
        return (nb - now < 10) ? (nb + divis) : (nb)
      end

      # find the nearest beat--earlier if we can do it, otherwise leave a gap
      # 
      def nearest_beat(now, first_event, divis = TICKS_4N)
        earlier_beat = next_beat(now - TICKS_4N)
        return (earlier_beat + first_event < now) ? next_beat(now) : earlier_beat
      end
      
    end
  end
end
