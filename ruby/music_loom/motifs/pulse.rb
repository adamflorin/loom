# 
#  pulse.rb: emit one or more notes in a regular rhythm on a given pitch
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Pulse < Motif
    
    # Emit one single note
    # 
    # TODO: input: # of steps
    # TODO: input: velocity
    # TODO: timescale
    # 
    def generate_gesture(now)
      Gesture.new(next_beat(now)) do |gesture|
        duration = TICKS_4N
        
        gesture.make :note, :at => 0, :data => {
          :pitch => @parameters[:pitch],
          duration => duration}

        gesture.make :done, :at => duration
      end
    end
    
  end
end
