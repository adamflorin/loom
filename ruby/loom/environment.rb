# 
#  environment.rb: shared data between players, methods for organizing them.
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
module Loom
  class Environment
    
    attr_accessor :players
    
    # 
    # 
    def initialize
      @players = []
    end
    
    # When players come online, they register themselves here
    # 
    def register_player(new_player)
      # add player
      @players << new_player
    end
      
  end
end
