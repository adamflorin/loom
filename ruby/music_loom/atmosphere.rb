# 
#  atmosphere.rb: the air in which players negotiate ensemble variables
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Atmosphere
    
    include Tonality
    
    attr_accessor :players, :density, :spotlight
    
    SCALE = [1/1, 5/4, 3/2, 7/4]
    
    def initialize(new_scale_id)
      load_scales
      
      @scale_id = new_scale_id
      @players = []
    end
    
    # When players come online, they register themselves here
    # 
    def register_player(new_player)
      @players << new_player
    end
    
  end
end
