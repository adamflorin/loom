# 
#  density.rb: behavior for player to follow global density
# 
#  "density" is the probability that the player will rest instead of
#  outputting a gesture (based on environment density).
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Behaviors
    module Density
      
      DENSITY_COEFF = 10
      
      # init
      # 
      def self.included(base)
        base.alias_method_chain :generate_gesture, :density
      end
      
      # decide whether to generate an event or to rest
      # 
      def generate_gesture_with_density(now)
        
        density_space = (1.0 - get_global(:environment).density) * DENSITY_COEFF + 1
        
        if (rand density_space).zero?
          
          # generate events
          generate_gesture_without_density(now)
        else
          
          # just put a rest on the queue
          Motif.rest(now)
        end
      end
      
    end
  end
end
