# 
#  ding.rb: the most dead simple motif possible:
#  just cue up one quarter note on middle C
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Ding < Motif
    
    # Go ding
    # 
    def generate_gesture(now, player_options = {})
      Gesture.new(Motif::next_beat(now)) do |gesture|
        duration = TICKS_4N
        
        gesture.make :note, :at => 0, :data => {
          :pitch => @options[:pitch],
          duration => duration}

        gesture.make :done, :at => duration
      end
    end
    
  end
end
