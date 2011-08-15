# 
#  chimes.rb
#  
#  Copyright May 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Drift < Player
    
    def initialize
      # notes = [64, 65, 69, 71, 72]
      notes = [60, 62, 66, 67, 70]
      
      @motifs = [
        { :class => Sigh,
          :options => {:next_beat_unit => Motif::TICKS_4N},
          :weight_param => {:celsius => 0.0}},
        { :class => Droplet,
          :options => {:notes => notes},
          :weight_param => {:celsius => 0.5}},
        { :class => Flutter,
          :options => {:notes => notes},
          :weight_param => {:celsius => 0.7}},
        # { :class => Pumpernickel,
        #   :options => {:notes => notes},
        #   :weight_param => {:celsius => 0.6}},
        {:class => Purr,
          :options => {:notes => notes},
          :weight_param => {:celsius => 0.8}}]
      
      @do_decay = false
      
      super
    end
    
  end
end
