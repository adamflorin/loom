# 
#  metronome.rb: simplest possible: ding ding ding
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Metronome < Player
    
    # include Behaviors::Density
    # include Behaviors::Loop
    # include Behaviors::Decay
    
    def initialize
      @motifs = [
        {:class => Bucephalus, :weight => 10},
        {:class => Ding, :weight => 10}]
      
      # @motifs = [
      #   {:class => Bucephalus, :weight => 2},
      #   {:class => Flipper, :weight => 20},
      #   {:class => Cirrus, :weight => 12},
      #   {:class => Pump, :weight => 10}]
      
      super
    end
    
  end
end
