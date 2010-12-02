# 
#  atmosphere.rb: the air in which players negotiate ensemble variables
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Atmosphere
    
    include Tonality
    
    attr_accessor :players, :density, :intensity, :deviance, :spotlight
    
    
    # 
    # 
    def initialize(new_scale_id)
      load_scales
      
      @scale_id = new_scale_id
      @players = []
    end
    
    # When players come online, they register themselves here
    # 
    def register_player(new_player)
      # add player
      @players << new_player
      
      # reconfigure ensemble
      set_player_focal_points
    end
    
    
    private
      
      # reset all players' focal points, round robin-style
      # 
      def set_player_focal_points
        spacing = 1.0 / @players.size
        
        @players.each_with_index do |player, i|
          # 0. - 1. position on the circle
          radial_pos = (i * spacing) + (spacing / 2)
          
          player.focal_point = MusicLoom::radial_to_coords(radial_pos)
        end
      end
      
  end
end
