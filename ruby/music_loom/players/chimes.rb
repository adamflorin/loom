# 
#  chimes.rb
#  
#  Copyright May 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Chimes < Player
    
    def initialize
      # notes = [64, 65, 69, 71, 72]
      notes = [60, 62, 66, 67, 70]
      
      @motifs = [
        { :class => Droplet, :weight => 10,
          :options => {:notes => notes}},
        { :class => Purr, :weight => 50,
          :options => {:notes => notes, :velocity => 127}}]
      
      @do_decay = false
      
      super
    end
    
  end
end
