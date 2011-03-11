# 
#  fog_machine.rb
#  
#  Copyright March 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class FogMachine < Player
    
    def initialize
      @gestures = [
        {:class => Sigh, :weight => 10}]      
      super
    end
    
  end
end
