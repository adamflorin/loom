# 
#  riddimz.rb: borrow liberally from amphibrach, but for drum racks
#  
#  Copyright March 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Riddimz < Motif
    
    ROOT_NOTE = 60
    NUM_DRUMS = 13
    
    # "morphological" parameters. typically overwritten by players.
    # 
    DEFAULT_OPTIONS = {
      # RHYTHM
      :swing_ratio => 0.0, # 0. - 2. (0. is strong short/long beats, 2.0 is triplets)
      :time_scale => 0.25, # time ratio (rounded to nearest power of 2)
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
    
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      # init
      events = []
      options = DEFAULT_OPTIONS.merge player_options
      
      # 
      start_time = Motif::next_beat(now, TICKS_8N).ceil #, TICKS_8N)
      event_time = start_time
      
      # select a random metric foot.
      use_foot = METRIC_FEET.keys[rand METRIC_FEET.size]
      stress_pattern = METRIC_FEET[use_foot]
      
      # time scale
      time_scale = round_to_power [options[:time_scale], MIN_TIME_SCALE].max
      
      stress_pattern.each_with_index do |stress, i|
        
        # ACCENT
        # 
        velocity = ((47 +
          (stress == :strong ? 40 : 0) +
          (40 - options[:swing_ratio])      # FIXME: 40 - 2.0????
        ) * options[:volume]).to_i.constrain(0..127)
        
        # RHYTHM
        # 
        dur = DEFAULT_DURATIONS[stress]
        
        # morph from strong 4/4 accents to tuplet
        tuplet_dur = (TICKS_4N / stress_pattern.size)
        dur += (tuplet_dur - dur) * (options[:swing_ratio] / 2.0)
        
        # apply time scale
        dur *= time_scale
        
        
        # "pitch" (= drum sample)
        # range = NUM_DRUMS.times.to_a.map{|x| x + ROOT_NOTE}
        region = [36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48]
        pitch = region[rand region.size]
        
        
        # event!
        events << [event_time.ceil, ["note", pitch, velocity, dur]]
        
        event_time += dur
      end
      
      events << [event_time.ceil, "done"]
      
      return events.sort{|x, y| x[0] <=> y[0]}, start_time
    end
    
  end
end
