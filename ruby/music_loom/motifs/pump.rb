# 
#  pump.rb: pump on 8ve
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Pump < Motif
    
    ROOT_NOTES = [47, 56, 50, 59, 60, 62]
    PATTERN = [TICKS_8N, TICKS_16N, TICKS_16N]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      start_time = Motif::next_beat(now) + TICKS_8N
      event_time = start_time
      
      accent = false
      pitch = ROOT_NOTES[rand ROOT_NOTES.length]
      
      PATTERN.each do |dur|
        # pre-
        velocity = accent ? 120 : 80
        
        # EVENT
        events << [event_time.ceil, ["note", pitch, velocity, dur]]
        
        # post-
        accent = !accent
        event_time += dur
        pitch = pitch + ((rand 3) - 1) * 12
      end
      
      return events, start_time
    end
    
  end
end
