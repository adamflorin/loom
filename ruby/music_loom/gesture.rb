# 
#  gesture.rb: base class for individual gestures (low-level patterns)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Gesture
    
    # tick values
    TICKS_4N = 480
    TICKS_8N = 240
    TICKS_16N = 120
    TICKS_32N = 60
    
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
      def next_beat(now)
        (now / 480).ceil * 480
      end
      
  end
end
