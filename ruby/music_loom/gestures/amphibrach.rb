# 
#  amphibrach.rb: flexible gesture with exposed morphological parameters
#  based on metric feet (poetry) and just intonation.
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Amphibrach < Gesture
    
    # # CONSTANTS
    # #
    
    # "morphological" parameters. typically overwritten by players.
    # 
    DEFAULT_OPTIONS = {
      # RHYTHM
      :swing_ratio => 0.2, # 0. - 1. (0. is strong short/long beats, 1.0 is triplets)
      :time_scale => 0.25, # time ratio (rounded to nearest power of 2)
      
      # TONALITY
      :melody_offset => 1.0, # pitch ratio
      :melody_arc => 1.0, # pitch ratio
      :melody_angle => 1.0, # pitch ratio
      
      # DYNAMICS/TIMBRE
      :volume => 0.75,
      
      # (unused)
      :portamento_dur => 0.0 # 0. - 1.
    }
    
    # stress patterns ("metric foot")
    # 
    METRIC_FEET = {
      :trochee => [:strong, :weak],
      :iamb => [:weak, :strong],
      :dactyl => [:strong, :weak, :weak],
      :spondee => [:strong, :strong],
      :amphibrach => [:weak, :strong, :weak]
    }
    
    DEFAULT_DURATIONS = {
      :weak => TICKS_16N,
      :strong => TICKS_8N
    }
    
    # ranges
    # 
    MIN_TIME_SCALE = 0.125
    
    
    # Generate a series of events based on core structure & above params
    # 
    def generate_events(now, player_options = {})
      # init
      options = DEFAULT_OPTIONS.merge player_options
      events = []
      
      # select a random metric foot.
      use_foot = METRIC_FEET.keys[rand METRIC_FEET.size]
      stress_pattern = METRIC_FEET[use_foot]
      
      # set event to start at next beat.
      event_time = Gesture::next_beat(now)
      
      # pull it back onto upbeat so that stress lands on downbeat...
      # won't always want this, but works for now.
      event_time -= DEFAULT_DURATIONS[:weak] if stress_pattern.first == :weak
      
      # and iterate through stresses!
      stress_pattern.each_with_index do |stress, i|
        
        # ACCENT
        # 
        velocity = ((47 +
          (stress == :strong ? 40 : 0) +
          (40 - options[:swing_ratio])
        ) * options[:volume]).to_i.constrain(0..127)
        
        
        # RHYTHM
        # 
        dur = DEFAULT_DURATIONS[stress]
        
        # morph from strong 4/4 accents to tuplet
        tuplet_dur = (TICKS_4N / stress_pattern.size)
        dur += (tuplet_dur - dur) * options[:swing_ratio]
        
        dur *= round_to_power [options[:time_scale], MIN_TIME_SCALE].max
        
        
        # PITCH (BEND)
        # 
        # apply melody ARC
        bend_ratio = (stress == :strong) ? options[:melody_arc] : 1.0
        
        # apply melody ANGLE
        angle_amount = (i.to_f / (stress_pattern.size - 1)) # 0. - 1.
        bend_ratio *= (options[:melody_angle] ** angle_amount)
        
        # apply melody OFFSET
        bend_ratio *= options[:melody_offset]
        
        # fit melody to SCALE
        bend_ratio = get_global(:atmosphere).fit_to_scale(bend_ratio)
        
        # output as pitch bend!
        pitch_bend = ratio_to_pitch_bend(bend_ratio)
        events << [event_time, ["bend", pitch_bend, dur * options[:portamento_dur]]]
        
        
        # => EVENT!
        # 
        events << [event_time, ["note", Tonality::BASE_PITCH, velocity, dur]]
        
        event_time += dur
      end
      
      # DONE event. if Player wants a longer pause, can just add another...?
      events << [event_time + 0, ["done"]]
    
      # NOTE! sorting events just in case they didn't end up that way...?
      return events.sort{|x, y| x[0] <=> y[0]}
    end
    
  end
end
