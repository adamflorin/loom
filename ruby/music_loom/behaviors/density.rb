# 
#  density.rb: behavior for player to follow density
# 
#  "density" is the probability that the player will rest instead of
#  outputting a gesture.
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Behaviors
    module Density
      
      DENSITY_COEFF = 10
      
      attr_accessor :density
      
      # init
      # 
      def self.included(base)
        base.alias_method_chain :make_gesture, :density
      end
      
      # decide whether to generate an event or to rest
      # 
      def make_gesture_with_density(now)
        density_space = (1.0 - @density.generate(0.0..1.0)) * DENSITY_COEFF + 1
        
        if (rand density_space).zero?
          
          # generate events
          make_gesture_without_density(now)
        else
          
          # just put a rest on the queue
          Motif.rest(now)
        end
      end
      
    end
  end
end
