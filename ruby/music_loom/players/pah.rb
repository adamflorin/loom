# 
#  pah.rb: pad-like
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

module MusicLoom
  class Pah < Player
    
    def initialize
      @motifs = [
        {:class => BackBeat, :weight => 10}]
      super
    end
    
  end
end
