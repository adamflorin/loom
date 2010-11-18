# 
#  gesture.rb: base class for individual gestures (low-level patterns)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Gesture
    
    # tick values
    TICKS_1N = 1920
    TICKS_2N = 960
    TICKS_4N = 480
    TICKS_8N = 240
    TICKS_16N = 120
    TICKS_32N = 60
    TICKS_64N = 30
    
    # populate event queue
    # 
    # for subclasses to overwrite
    # 
    def generate_events(now)
      []
    end
    
    def self.rest(now)
      [next_beat(now), "done"]
    end
    
    
    private
      
      # return time of next downbeat (in ticks)
      # 
      def self.next_beat(now, divis = TICKS_4N)
        nb = (now.to_f / divis).ceil * divis
        
        # if time is really tight (i.e., generate_gesture event came in _right on_ a beat)
        # then just skip to next beat rather than letting it fail.
        return (nb - now < 10) ? (nb + divis) : (nb)
      end
      
      # math util.
      # 
      # TODO: cache coefficients after 1st calc
      # 
      def ratio_to_pitch_bend(ratio)
        # ratio to midi note (0 = unison)
        note_delta = (12.0 / Math.log(2)) * Math.log(ratio)
        
        # then to 14-bit pitch bend
        pitch_bend = (note_delta/12.0 + 1.0) * 8192.0
        
        return pitch_bend.to_i
      end
      
      # to manage things like timescale shifts which for now 
      # must be divisible by 2
      # 
      def round_to_power(x, power = 2)
        power ** (Math.log(x) / Math.log(power)).round
      end
      
  end
end
