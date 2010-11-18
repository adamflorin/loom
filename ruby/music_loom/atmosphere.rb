# 
#  atmosphere.rb: the air in which players negotiate ensemble variables
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Atmosphere
    
    attr_accessor :players, :density, :spotlight
    
    SCALE = [1/1, 5/4, 3/2, 7/4]
    
    def initialize
      @players = []
    end
    
    # When players come online, they register themselves here
    # 
    def register_player(new_player)
      @players << new_player
    end
    
  end
end
