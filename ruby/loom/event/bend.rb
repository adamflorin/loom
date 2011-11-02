# 
#  bend.rb: MIDI pitch bend event
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Event
    
    class Bend < Event
      
      # serialize bend event into format Max xbendout likes
      # 
      def output(data = nil)
        super([@data[:pitch_bend], @data[:duration]])
      end
      
      
      private
        
        def default_data
          { :pitch_bend => 0,
            :duration => TICKS_4N}
        end
        
    end
    
  end
end
