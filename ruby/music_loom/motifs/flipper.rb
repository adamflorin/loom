# 
#  flipper.rb: just flip on whole step in changing rhythm
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Flipper < Motif
    
    ROOT_NOTE = 60
    
    # 
    # 
    def generate_gesture(now, player_options = {})
      Gesture.new(Motif::next_beat(now, TICKS_8N)) do |gesture|
        event_time = 0
        high_note = false
        num_steps = (rand * 3).to_i + 2
        accent = true

        num_steps.times do |i|
          gesture.make :note, :at => event_time, :data => {
            :pitch => ROOT_NOTE + (high_note ? ((rand * 10).to_i.zero? ? 8 : 2) : 0),
            :velocity => (accent ? 100 : 20),
            :duration => TICKS_16N
          }

          # post-
          accent = false
          high_note = !high_note

          # increment event_time
          event_time += TICKS_16N
        end

        # finish up with a "done" event
        # chance to add rest after gesture if desired.
        gesture.make :done, :at => event_time + TICKS_16N
      end
    end
    
  end
end
