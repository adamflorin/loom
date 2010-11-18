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
    
    # 0. is strong short/long beats, 1.0 is triplets
    SWING_RATIO = 0.2 # 0. - 1.
    
    TIME_SCALE = 1.0 # 1/2, 1, 2, etc.
    
    
    # # SCALES
    # # 
    
    # JI "major" scale (?)... very sweet + endearing
    PITCH_RATIOS = [1.0, 9/8.0, 5/4.0, 4/3.0, 3/2.0, 5/3.0, 7/4.0]
        
    # JI octotonic... a bit square with those high prime numerators
    # PITCH_RATIOS = [1.0, 9/8.0, 5/4.0, 11/8.0, 3/2.0, 13/8.0, 7/4.0, 15/8.0]
    
    # JI "pentatonic" scale... off-kilter quality
    # PITCH_RATIOS = [5/5.0, 6/5.0, 7/5.0, 8/5.0, 9/5.0]
    
    # m3?
    # PITCH_RATIOS = [1.0, 13/11.0]
    
    # JI "mixto"
    # PITCH_RATIOS = [1.0, 6/5.0, 5/4.0, 3/2.0, 8/5.0, 7/4.0, 9/5.0]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now)
      events = []
      event_time = Gesture::next_beat(now)
      
      STRESSES.each do |stress|
        
        velocity = 40 + (stress ? 40 : 0) * (1.0 - SWING_RATIO)
        
        
        dur = stress ? TICKS_8N : TICKS_16N
        
        # morph from strong 4/4 accents to tuplet
        tuplet_dur = (TICKS_4N / STRESSES.size)
        dur += (tuplet_dur - dur) * SWING_RATIO
        
        dur *= TIME_SCALE
        
        # pitch bend
        bend_ratio = PITCH_RATIOS[rand PITCH_RATIOS.size]
        # bend_ratio = 1 / bend_ratio if (rand 2).zero? # inversions!
        pitch_bend = ratio_to_pitch_bend(bend_ratio)
        events << [event_time, ["bend", pitch_bend]]
        
        # TODO: find closest pitch; avoid giant leaps...?
        
        # pitch = 60 + (rand 12) * (rand 2)
        pitch = 48 + 12 * (rand 2)
        
        # finally, note event
        events << [event_time, ["note", pitch, velocity, dur]]
        
        event_time += dur
        
      end
      
      
      events << [event_time, ["done"]]
      
      # NOTE! sorting events just in case they didn't end up that way...?
      return events.sort{|x, y| x[0] <=> y[0]}
    end
    
  end
end
