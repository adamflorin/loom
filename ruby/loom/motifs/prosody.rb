# 
#  prosody.rb: flexible gesture with exposed morphological parameters
#  based on metric feet (poetry).
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
module Loom
  class Prosody < Motif
    
    # metric feet ("stress patterns")
    # 
    METRIC_FEET = {
      :trochee => [:strong, :weak],
      :iamb => [:weak, :strong],
      :dactyl => [:strong, :weak, :weak],
      :spondee => [:strong, :strong],
      :amphibrach => [:weak, :strong, :weak]
    }
    
    # 
    # 
    DEFAULT_DURATIONS = {
      :weak => TICKS_16N,
      :strong => TICKS_8N
    }
    
    # ranges
    # 
    MIN_TIME_SCALE = 0.125
    
    # overwrite default_parameters
    # 
    def default_parameters
      {
        # RHYTHM
        :swing_ratio => 0.0, # 0. - 2. (0. is strong short/long beats, 2.0 is triplets)
        :time_scale => 1.0, # time ratio (rounded to nearest power of 2)
        
        # TONALITY
        :melody_offset => 1.0, # pitch ratio
        :melody_arc => 1.0, # pitch ratio
        :melody_angle => 1.0, # pitch ratio
        
        # DYNAMICS/TIMBRE
        :volume => 0.75,
        
        # (unused)
        :portamento_dur => 0.0 # 0. - 1.
      }
    end
    
    # Generate a series of events based on core structure & above params
    # 
    def generate_gesture(now)
      Gesture.new(Motif::next_beat(now)) do |gesture|
        event_time = 0
        
        # select metric foot
        # 
        foot_key = METRIC_FEET.keys[rand METRIC_FEET.size]
        metric_foot = METRIC_FEET[foot_key]
        
        # each step in foot
        # 
        metric_foot.each_with_index do |stress, i|
          # duration for note + pitch bend must line up
          duration = duration(stress, metric_foot.size)
          
          # out pitch as pitch bend
          gesture.make :bend, :at => event_time.ceil, :data => {
            :pitch_bend => ratio_to_pitch_bend(bend_ratio(stress, metric_foot.size, i)),
            :duration => duration * @parameters[:portamento_dur]}
          
          # + a static note
          gesture.make :note, :at => event_time.ceil, :data => {
            :pitch => Tonality::BASE_PITCH,
            :velocity => velocity(stress),
            :duration => duration}

          event_time += duration
        end
        
        gesture.make :done, :at => event_time
      end
    end
    
    
    private
      
      # 
      # 
      def time_scale
        round_to_power [@parameters[:time_scale], MIN_TIME_SCALE].max
      end
      
      # 
      # 
      def velocity(stress)
        ((47 +
          (stress == :strong ? 40 : 0) +
          (40 - @parameters[:swing_ratio])      # FIXME: 40 - 2.0????
        ) * @parameters[:volume]).to_i.constrain(0..127)
      end
      
      # 
      # 
      def duration(stress, num_steps)
        duration = DEFAULT_DURATIONS[stress]
        
        # morph from strong 4/4 accents to tuplet
        tuplet_duration = (TICKS_4N / num_steps)
        duration += (tuplet_duration - duration) * (@parameters[:swing_ratio] / 2.0)

        # apply time scale
        duration *= time_scale
        
        return duration
      end
      
      # 
      # 
      def bend_ratio(stress, num_steps, i)
        bend_ratio = (stress == :strong) ? @parameters[:melody_arc] : 1.0

        # apply melody ANGLE
        angle_amount = (i.to_f / (num_steps - 1)) # 0. - 1.
        bend_ratio *= (@parameters[:melody_angle] ** angle_amount)

        # apply melody OFFSET
        bend_ratio *= @parameters[:melody_offset]

        # fit melody to SCALE
        bend_ratio = get_global(:environment).fit_to_scale(bend_ratio)

        # FIXME: sanity check!!
        return bend_ratio || 1.0
      end
      
  end
end
