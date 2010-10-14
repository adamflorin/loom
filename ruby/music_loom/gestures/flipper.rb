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
    def generate_events(now)
      events = []
      event_time = next_beat(now)
      
      high_note = false
      accent = false
      num_steps = (rand * 3).to_i + 2
      
      num_steps.times do |i|
          
        high_note = !high_note
        
        pitch = ROOT_NOTE + (high_note ? ((rand * 10).to_i.zero? ? 8 : 2) : 0)
        
        velocity = accent ? 100 : 20
        
        events << [event_time, ["note", pitch, velocity, TICKS_16N]]
        
        event_time += TICKS_16N
        
      end
      
      return events
    end
    
  end
end
