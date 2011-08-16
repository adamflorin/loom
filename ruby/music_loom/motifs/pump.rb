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
    def generate_gesture(now, player_options = {})
      Gesture.new(Motif::next_beat(now) + TICKS_8N) do |gesture|
        event_time = 0

        accent = false
        pitch = ROOT_NOTES[rand ROOT_NOTES.length]

        PATTERN.each do |dur|
          gesture.make :note, :at => event_time, :data => {
            :pitch => pitch,
            :velocity => (accent ? 120 : 80),
            :duration => dur
          }

          # post-
          accent = !accent
          event_time += dur
          pitch = pitch + ((rand 3) - 1) * 12
        end
      end
    end
    
  end
end
