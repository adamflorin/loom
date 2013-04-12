# 
#  controller.rb: MIDI controller event
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Event
    
    class Controller < Event
      
      # serialize bend event for Max
      # 
      def output(data = nil)
        super([@data[:controller], @data[:value], @data[:ramp_time]])
      end
      
      
      private
        
        def default_data
          { :controller => 64,
            :value => 0,
            :ramp_time => 0}
        end
        
    end
    
  end
end
