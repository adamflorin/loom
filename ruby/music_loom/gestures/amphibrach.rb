# 
#  pump.rb: pump on 8ve
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Amphibrach < Gesture
    
    # # CONSTANTS
    # #
    
    STRESSES = [false, true, false]
    
    
    # # SCALES
    # # 
    
    # FIXME: pitches
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, options = {})
      
      # set up default options!
      
      # 0. is strong short/long beats, 1.0 is triplets
      options[:swing_ratio] ||= 0.2 # 0. - 1.
      
      # will be rounded to nearest power of 2
      options[:time_scale] ||= 1.0 # 1/2, 1, 2, etc.
      
      options[:bend_dur_ratio] ||= 0.0 # 0. - 1.
      
      
      pitches = Tonality::
      
      events = []
      event_time = Gesture::next_beat(now) - TICKS_16N
      
      STRESSES.each do |stress|
        
        velocity = 40 + (stress ? 40 : 0) * (1.0 - options[:swing_ratio])
        
        
        dur = stress ? TICKS_8N : TICKS_16N
        
        # morph from strong 4/4 accents to tuplet
        tuplet_dur = (TICKS_4N / STRESSES.size)
        dur += (tuplet_dur - dur) * options[:swing_ratio]
        
        dur *= round_to_power(options[:time_scale])
        
        # pitch bend
        bend_ratio = pitches[rand pitches.size]
        # bend_ratio = 1 / bend_ratio if (rand 2).zero? # inversions!
        pitch_bend = ratio_to_pitch_bend(bend_ratio)
        events << [event_time, ["bend", pitch_bend, dur * options[:bend_dur_ratio]]]
        
        # TODO: find closest pitch; avoid giant leaps...?
        
        # pitch = 60 + (rand 12) * (rand 2)
        pitch = 48 + 12 * (rand 2)
        
        # finally, note event
        events << [event_time, ["note", pitch, velocity, dur]]
        
        event_time += dur
        
      end
      
      
      events << [event_time + 0, ["done"]]
      
      # NOTE! sorting events just in case they didn't end up that way...?
      return events.sort{|x, y| x[0] <=> y[0]}
    end
    
  end
end
