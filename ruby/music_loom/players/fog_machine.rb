# 
#  fog_machine.rb
#  
#  Copyright March 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class FogMachine < Player
    
    def initialize
      # notes = 13.times.to_a.map{|x| x+36}
      notes = [36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48]
      
      @motifs = [
        {:class => Riddimz, :weight => 100},
        {:class => Purr, :weight => 10},
        {:class => Pump, :weight => 10},
        # {:class => Pumpernickel, :weight => 10, :options => {:notes => notes}},
        {:class => Cirrus, :weight => 50, :options => {:notes => notes}}]
      
      @do_decay = false
      
      super
    end
    
  end
end
