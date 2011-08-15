# 
#  umm_yeah_sure.rb
#  JJS first gesture
#  
#  Created by Jasper Speicher on 2011-03-29.
#  Copyright 2011. All rights reserved.
# 
module MusicLoom
  class UmmYeahSure < Motif
    
    #roots = [60,65,67]    
    ROOT_NOTE = 60 #roots[rand(roots.count)]
    
    # 
    # 
    def generate_events(now, player_options = {})
      #notes = [0,2,5,8,5,8,2,8,7,5,0]
      #notes = [0,0,0,4,4,5,9,9,9,11]
      notes = [0,0,0,7,7,7,9]
      events = []
      # start_time & event_time are just timestamps in ticks
      start_time = Motif::next_beat(now, TICKS_32N) #TICKS_8N)
      event_time = start_time
      
      high_note = false
      num_steps = (rand * notes.count).to_i + 2
      # accent = true
      pitch_index = 0;
      
      num_steps.times do |i|
        # pre-
        # pitch is a MIDI note
        #pitch = ROOT_NOTE  + (high_note ? ((rand * 10).to_i.zero? ? 8 : 2) : 0)
        pitch = ROOT_NOTE + notes[pitch_index.modulo(notes.count)]
        pitch_index = pitch_index + (rand * notes.count/4).to_i
        
        # velocity is 0-127
        velocity = 100 #accent ? 100 : 20
        
        # duration is in ticks
        duration = TICKS_32N * (1+ (rand * 3).to_i + 2)
        
        # EVENT
        events << [event_time, ["note", pitch, velocity, duration]]
        
        # DEV. controller
        controller_number = 64
        val = 70
        ramp_time = 0
        events << [event_time, ["controller", controller_number, val, ramp_time]]
        
        # post-
        # accent = false
        high_note = !high_note
        
        # increment event_time
        event_time += duration
      end
      
      # finish up with a "done" event
      # chance to add rest after gesture if desired.
      events << [event_time + TICKS_16N, "done"]
      
      return events, start_time
    end
    
  end
end
