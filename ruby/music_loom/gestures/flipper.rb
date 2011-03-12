# 
#  flipper.rb: just flip on whole step in changing rhythm
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Flipper < Gesture
    
    ROOT_NOTE = 60
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      event_time = Gesture::next_beat(now, TICKS_8N)
      
      high_note = false
      num_steps = (rand * 3).to_i + 2
      accent = true
      
      num_steps.times do |i|
        # pre-
        pitch = ROOT_NOTE + (high_note ? ((rand * 10).to_i.zero? ? 8 : 2) : 0)
        velocity = accent ? 100 : 20
        
        # EVENT
        events << [event_time.ceil, ["note", pitch, velocity, TICKS_16N]]
        
        # post-
        accent = false
        high_note = !high_note
        event_time += TICKS_16N
      end
      
      events << [event_time.ceil + TICKS_16N, "done"]
      
      return events
    end
    
  end
end
