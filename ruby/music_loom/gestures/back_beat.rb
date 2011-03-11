# 
#  flipper.rb: just flip on whole step in changing rhythm
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class BackBeat < Gesture
    
    ROOT_NOTE = 60
    INTERVALS = [2, 5, 9, 11]
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      event_time = Gesture::next_beat(now)
      
      do_8ve_up = (rand 3).zero?
      on_downbeat = (rand 3).zero?
      do_doubles = (rand 4).zero?
      
      event_time += TICKS_8N unless on_downbeat
      
      duration = 50 # TICKS_2N
      velocity = do_8ve_up ? 70 : 100 #rand 20 + 100
      # pitch = ROOT_NOTE + INTERVALS[rand INTERVALS.length]
      
      bottom_note = [62, 60][rand 2] + (do_8ve_up ? 12 : 0)
      middle_note = [65, 64][rand 2] + (do_8ve_up ? 12 : 0)
      top_note = [69, 71][rand 2] + (do_8ve_up ? 12 : 0)
      
      if on_downbeat
        downbeat_note = [80, 82, 84][rand 2]
        events << [event_time, ["note", downbeat_note, 120, duration]]
        event_time += TICKS_8N
      end
      
      # make a chord??
      2.times do
        events << [event_time, ["note", 62, velocity, duration]]
        events << [event_time, ["note", middle_note, velocity, duration]]
        events << [event_time, ["note", top_note, velocity * 1.2, duration]]
        
        event_time += do_doubles ? TICKS_8N : TICKS_4N
        duration = 250
      end
      
      events << [event_time + (do_doubles ? 0 : -TICKS_8N), "done"]
      
      return events
    end
    
  end
end
