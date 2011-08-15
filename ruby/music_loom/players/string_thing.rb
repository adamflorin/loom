# 
#  string_thing.rb: for use with Tension string physical modeler
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class StringThing < Player
    
    def initialize
      @motifs = [
        {:class => Bucephalus, :weight => 2},
        {:class => Flipper, :weight => 20},
        {:class => Cirrus, :weight => 12},
        {:class => Pump, :weight => 10}]
      
      @do_decay = false
      
      super
    end
    
  end
end
