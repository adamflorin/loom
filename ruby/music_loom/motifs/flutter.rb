# 
#  run.rb: stacatto descending
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Flutter < Motif
    
    ROOT_NOTE = 41
    
    # set up a note to play faster & faster
    # 
    def generate_gesture(now, player_options = {})
      events = []
      start_time = Motif::next_beat(now, @options[:next_beat_unit] || TICKS_8N)
      event_time = start_time
            
      duration = 50 # TICKS_2N
      velocity = 100 #rand 20 + 100
      
      pitch = unless @options[:notes].nil?
        @options[:notes][rand @options[:notes].size]
      else
        ROOT_NOTE
      end
      
      tick_size = TICKS_32N * (rand(6) + 1)
      
      4.times do
        events << [event_time.ceil, ["note", pitch, 80, tick_size/2]]
        
        event_time += tick_size
      end
      
      events << [event_time, "done"]
      
      return events, start_time
    end
    
  end
end
