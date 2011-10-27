# 
#  gesture.rb: base class for individual gestures (low-level patterns)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Motif
    
    attr_accessor :device_id, :weight, :parameters
    
    # tick values
    TICKS_1N = 1920
    TICKS_2N = 960
    TICKS_4N = 480
    TICKS_8N = 240
    TICKS_16N = 120
    TICKS_32N = 60
    TICKS_64N = 30
    
    # 
    # 
    def initialize(device_id)
      @device_id = device_id
      @parameters = default_parameters
    end
    
    def default_parameters
      {}
    end
    
    # main motif logic for subclasses to overwrite
    # 
    def generate_gesture(now)
      Motif.rest(now)
    end
    
    # generate a rest, i.e. a silent gesture
    # 
    def self.rest(now)
      return Gesture.new(next_beat(now)) do |gesture|
        gesture.make :done, :at => 0
      end
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
      
      # find the nearest beat--earlier if we can do it, otherwise leave a gap
      # 
      def self.nearest_beat(now, first_event, divis = TICKS_4N)
        earlier_beat = next_beat(now - TICKS_4N)
        return (earlier_beat + first_event < now) ? next_beat(now) : earlier_beat
      end
      
      # get parameter with option to deviate
      # 
      # TODO: create proper Parameter property, so we don't
      # just throw :*_deviation and :*_output values in there.
      # 
      # The reason not to do that now has to do with [autopattr]
      # load order in max.
      # 
      def parameter(key)
        output_key = "#{key.to_s}_output".to_sym
        value = @parameters[key]
        deviation = @parameters["#{key.to_s}_deviation".to_sym]
        
        if value.is_a?(Float) and !!deviation
          return @parameters[output_key] = deviate(value, @parameters[output_key], deviation / 100.0)
        else
          return value
        end
      end
      
      # shoot toward target value
      # 
      # NOTE: deviation is used two ways:
      # - once as the parameter to gaussian_rand
      # - then again as a constraint for how much to listen to randomness
      # 
      # FIXME: as a result of the above, if you crank deviation up,
      # then bring it back to 0, you won't ever get back the input_value!!
      # because it can't take steps to make it back! this needs more thought.
      # 
      def deviate(input_value, last_output_value, deviation)
        
        # random but near(-ish) the value
        near_value = MusicLoom::gaussian_rand(input_value, deviation)
        
        # TODO: constrain near_value?
        # .constrain(0.0..2.0)
        
        # first time this motif is being run
        last_output_value ||= near_value
        
        return last_output_value + (near_value - last_output_value) * deviation
      end
      
      # math util.
      # 
      # TODO: cache coefficients after 1st calc
      # 
      def ratio_to_pitch_bend(ratio)
        pitch_bend = if ratio > 0
          # ratio to midi note (0 = unison)
          note_delta = (12.0 / Math.log(2)) * Math.log(ratio)

          # then to 14-bit pitch bend
          (note_delta/12.0 + 1.0) * 8192.0
        else
          0
        end
        return pitch_bend
      end
      
      # to manage things like timescale shifts which for now 
      # must be divisible by 2
      # 
      def round_to_power(x, power = 2)
        power ** (Math.log(x) / Math.log(power)).round
      end
      
      # TEMP I think... just to retrofit old gestures into new
      # ratio-based system
      # 
      def mtof(midi_note)
        return (440.0 * Math.exp(0.057762265 * (midi_note - 69.0)))
      end
      
  end
end
