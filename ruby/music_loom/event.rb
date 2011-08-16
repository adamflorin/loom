# 
#  event.rb: simple struct for MIDI events
# 
#  tbd: always store events in canonical form?
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Event
    
    attr_accessor :time, :data
    
    # only necessary if time is non-canonical...
    # maybe this should apply to gestures?
    # 
    def minus_time_offset(offset)
      # TODO
    end
    
  end
end
