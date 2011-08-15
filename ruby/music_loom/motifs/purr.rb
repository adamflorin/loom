# 
#  run.rb: stacatto descending
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Purr < Motif
    
    ROOT_NOTE = 41
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, player_options = {})
      events = []
      start_time = Motif::next_beat(now, @options[:next_beat_unit] || TICKS_8N)
      event_time = start_time
            
      duration = 50 # TICKS_2N
      velocity = @options[:velocity]|| 80 #rand 20 + 100
      # pitch = ROOT_NOTE + INTERVALS[rand INTERVALS.length]
      
      pitch = unless @options[:notes].nil?
        @options[:notes][rand @options[:notes].size]
      else
        ROOT_NOTE
      end
      
      events << [event_time, ["bend", ratio_to_pitch_bend(1.0)]]
      
      rate = TICKS_64N / (2 ** (rand 3))
      
      (rand(8) + 2).times do
        events << [event_time.ceil, ["note", pitch, velocity, rate / 2]]
        
        event_time += rate
      end
      
      events << [event_time, "done"]
      
      return events, start_time
    end
    
  end
end
