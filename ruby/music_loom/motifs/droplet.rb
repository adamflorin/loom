# 
#  droplet.rb
#  
#  Copyright December 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Droplet < Motif
    
    ROOT_NOTE = 36
    DUR = TICKS_32N
    # PATTERN = [TICKS_8N, TICKS_16N, TICKS_16N]
    # DESCENDING_NOTES = [0, -1, -1, -3, -3, -7, -10, -11]
    
    DEFAULT_OPTIONS = {
      # DYNAMICS/TIMBRE
      :volume => 0.75,
    }
    
    REGIONS = {
      :cuica => [38, 42, 36, 50],
      :breath => [44, 46, 47] #, 51]
    }
    
    # set up a note to play faster & faster
    # 
    def generate_gesture(now, player_options = {})
      
      options = DEFAULT_OPTIONS.merge player_options
      
      region_no = options[:region].to_i.constrain(0..1)
      
      events = []
      start_time = Motif::next_beat(now, DUR * (region_no.zero? ? 4 : 1))
      event_time = start_time
      
      events << [event_time, ["bend", ratio_to_pitch_bend(1.0)]]
      
      # (rand 3).times do
      # PATTERN.each do |dur|
        # pre-
        dur = DUR * (2 ** (rand 5))
        velocity = (150.0 * options[:volume]).to_i.constrain(0..127)
        
        event_time += DUR / 2 if (rand 2).zero?
        
        # pitch = CUICA[rand CUICA.size]
        # pitch = BREATH[rand BREATH.size]
        # pitch = ROOT_NOTE + (rand 16) # DESCENDING_NOTES[desc_by]
        pitch = unless @options[:notes].nil?
          @options[:notes][rand @options[:notes].size]
        else
          region = REGIONS.values[options[:region].to_i.constrain(0..1)]
          region[rand region.size]
        end
      
        
        # EVENT
        events << [event_time, ["note", pitch, velocity, dur]]
        
        # post-
        # accent = false
        # event_time += dur
        # desc_by += rand 3
      # end
      
      events << [event_time + dur, "done"]
      
      return events, start_time
    end
    
  end
end
