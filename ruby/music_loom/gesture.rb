# 
#  gesture.rb: base class for individual gestures (low-level patterns)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Gesture
    
    # tick values
    TICKS_1N = 1920
    TICKS_2N = 960
    TICKS_4N = 480
    TICKS_8N = 240
    TICKS_16N = 120
    TICKS_32N = 60
    TICKS_64N = 30
    
    # populate event queue
    # 
    # for subclasses to overwrite
    # 
    def generate_events(now)
      []
    end
    
    
    private
      
      # return time of next downbeat (in ticks)
      # 
      def next_beat(now, divis = TICKS_4N)
        nb = (now.to_f / divis).ceil * divis
        
        # if time is really tight (i.e., generate_gesture event came in _right on_ a beat)
        # then just skip to next beat rather than letting it fail.
        return (nb - now < 10) ? (nb + divis) : (nb)
      end
      
  end
end
