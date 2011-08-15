# 
#  string_thing.rb: for use with Tension string physical modeler
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Vibes < Player
    
    def initialize
      @motifs = [
        {:class => Amphibrach, :weight => 10}]
      
      @do_decay = false
      
      super
    end
    
  end
end
