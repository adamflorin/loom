# 
#  string_thing.rb: for use with Tension string physical modeler
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Vibes < Player
    
    def initialize
      @gestures = [
        {:class => Amphibrach, :weight => 10}]
      
      super
    end
    
  end
end
