# 
#  umm_yeah_sure.rb
#  JJS first gesture
#  
#  Created by Jasper Speicher on 2011-03-29.
#  Copyright 2011. All rights reserved.
# 
module MusicLoom
  class WarmVibe < Motif
    
    ROOT_NOTE = 60
    
    # 
    # 
    def generate_gesture(now, player_options = {})
      events = []
      # start_time & event_time are just timestamps in ticks
      start_time = Motif::next_beat(now, @options[:next_beat_unit] || TICKS_8N)
      event_time = start_time
      
      # high_note = false
      num_steps = (rand * 3).to_i + 2
      # accent = true
      
      num_steps.times do |i|
        # pre-
        # pitch is a MIDI note
        pitch = ROOT_NOTE # + (high_note ? ((rand * 10).to_i.zero? ? 8 : 2) : 0)
        
        # velocity is 0-127
        velocity = 100 #accent ? 100 : 20
        
        # duration is in ticks
        duration = TICKS_16N
        
        # EVENT
        events << [event_time, ["note", pitch, velocity, duration]]
        
        # DEV. controller
        controller_number = 64
        val = 70
        ramp_time = 0
        events << [event_time, ["controller", controller_number, val, ramp_time]]
        
        # post-
        # accent = false
        # high_note = !high_note
        
        # increment event_time
        event_time += TICKS_16N
      end
      
      # finish up with a "done" event
      # chance to add rest after gesture if desired.
      events << [event_time + TICKS_16N, "done"]
      
      return events, start_time
    end
    
  end
end
