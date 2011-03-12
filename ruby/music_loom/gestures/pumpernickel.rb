# 
#  pump.rb: pump on 8ve
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Pumpernickel < Gesture
    
    ROOT_NOTES = [47, 56, 50, 59, 60, 62]
    PATTERN = [TICKS_16N, TICKS_8N, TICKS_16N, TICKS_16N, TICKS_16N, TICKS_8N]
    # PATTERN = [TICKS_8N]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, options = {})
      events = []
      
      # check globals
      num_events = PATTERN.size # * (1.0 - get_global(:brevity)) + 1
      
      # PATTERN[0] = TICKS_32N if get_global(:brevity > 0.9)
      
      # mainly so that it's tight in hocket mode
      event_time = Gesture::next_beat(now, PATTERN.first)
      
      accent = false
      pitch = ROOT_NOTES[rand ROOT_NOTES.length]
      
      PATTERN.slice(0, num_events).each do |dur|
        # pre-
        velocity = accent ? 120 : 80
        
        
        # PITCH TWEAK
        bend_ratio = mtof(pitch) / 261.62558
        
        # fit melody to SCALE
        bend_ratio = get_global(:atmosphere).fit_to_scale(bend_ratio)
        
        # output as pitch bend!
        pitch_bend = ratio_to_pitch_bend(bend_ratio)
        events << [event_time.ceil, ["bend", pitch_bend, dur * 0.25]]
        
        
        # EVENT
        events << [event_time.ceil, ["note", Tonality::BASE_PITCH, velocity, dur]]
        
        # post-
        accent = !accent
        event_time += dur
        # pitch = pitch + ((rand 3) - 1) * 12
      end
      
      events << [event_time, "done"]
      
      return events
    end
    
  end
end
