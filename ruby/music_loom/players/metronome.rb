# 
#  metronome.rb: simplest possible: ding ding ding
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Metronome < Player
    
    include Behaviors::Density
    
    def initialize
      @motifs = [
        {:class => Ding, :weight => 10}]
      
      super
    end
    
  end
end
