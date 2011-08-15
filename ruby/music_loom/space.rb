# 
#  space.rb: pixel geometry for player "space"
#  
#  Copyright December 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Space
    module ClassMethods
      
      # geometry constants
      # 
      AXIS_LENGTH = 1.0 # (box is 0. - 1. on each axis)
      CIRCLE_RADIUS = 0.35 # theoretical max.: 0.5
      UMBRA_RADIUS = 0.45
      PENUMBRA_RADIUS = 0.55
      
      # 
      # 
      def radial_to_coords(radial_pos)
        # trigify (& subtract 0.25 so that origin is on bottom, not right)
        theta = (radial_pos - 0.25) * (2 * Math::PI)
        
        return [
          polar_to_cartesian(Math.cos(theta)),
          polar_to_cartesian(Math.sin(theta))]
      end
      
      # 
      # 
      def spotlight_focus(player)
        spotlight_x, spotlight_y = get_global(:environment).spotlight
        player_x, player_y = player
        
        # pythag.
        distance = Math.sqrt((spotlight_x - player_x) ** 2 + (spotlight_x - player_y) ** 2)
        
        return 1.0 - (distance.constrain(UMBRA_RADIUS..PENUMBRA_RADIUS) - UMBRA_RADIUS) /
          (PENUMBRA_RADIUS - UMBRA_RADIUS)
      end
      
      
      private
      
        # util.
        # TODO: centralize geometry code
        # 
        def polar_to_cartesian(thing)
          (thing * CIRCLE_RADIUS + (AXIS_LENGTH / 2.0))
        end
      
    end
    
    def self.included(receiver)
      receiver.extend ClassMethods
    end
  end
end
