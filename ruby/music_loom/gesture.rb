# 
#  gesture.rb: base class for individual gestures (low-level patterns)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Gesture
    
    # populate event queue
    # 
    # for subclasses to overwrite
    # 
    def generate_events(now)
      []
    end
    
  end
end
