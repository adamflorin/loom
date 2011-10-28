# 
#  pulse.rb: emit one or more notes in a regular rhythm on a given pitch
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Pulse < Motif
    
    # because enum'd live.dials only output the INDEX of the dial! silly!
    TIMESCALE_VALUES = [TICKS_64N, TICKS_32N, TICKS_16N, TICKS_8N, TICKS_4N, TICKS_2N, TICKS_1N]    
    
    # Emit one single note
    # 
    # TODO: input: velocity
    # 
    def generate_gesture(now)
      Gesture.new(Motif::next_beat(now)) do |gesture|
        event_time = 0
        timescale_index = parameter(:timescale).round
        rate = TIMESCALE_VALUES[timescale_index.constrain(0..TIMESCALE_VALUES.size-1)]
        
        parameter(:steps).to_i.constrain(0..16).times do |i|
          gesture.make :note, :at => event_time, :data => {
            :pitch => parameter(:pitch),
            :duration => rate}
          event_time += rate
        end

        gesture.make :done, :at => event_time
      end
    end
    
  end
end
