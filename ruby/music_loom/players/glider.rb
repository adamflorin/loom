# 
#  string_thing.rb: for use with Tension string physical modeler
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Glider < Player
    
    def initialize
      @motifs = [
        { :class => Purr,
          :options => {:next_beat_unit => Motif::TICKS_64N},
          :weight_param => {:temperature => 1.0}},
        { :class => Flutter,
          :options => {:next_beat_unit => Motif::TICKS_64N},
          :weight_param => {:temperature => 0.5}},
        { :class => Droplet,
          # :options => {:notes => notes},
          :weight_param => {:temperature => 0.0}}]
        # { :class => Sigh,
        #   :options => {:next_beat_unit => Motif::TICKS_64N},
        #   :weight_param => {:temperature => 0.0}}]
      
      @do_density = false
      
      super
    end
    
  end
end
