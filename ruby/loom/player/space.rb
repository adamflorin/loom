# 
#  space.rb: the player's position in a virtual space.
#  player may be more or less "in focus" based on user's own position
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Player
    module Space
      
      attr_accessor :focal_point
      
      def self.included(base)
        base.alias_method_chain :deviance, :space
        base.alias_method_chain :generate_motif_options, :space
      end
      
      
      private
        
        # factor in player spotlight focus (0. - 1.)
        # 
        def deviance_with_space
          deviance_without_space * Loom::spotlight_focus(@focal_point)
        end
        
        def generate_motif_options_with_space
          generate_motif_options_without_space
          
          # volume is a factor of focus + global intensity
          @motif_options[:volume] = focus * get_global(:environment).intensity.constrain(0.1..1.0)
        end
        
    end
  end
end
