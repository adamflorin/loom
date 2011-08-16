# 
#  cirrus.rb: high-up cloud, curving subtlely downward
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Cirrus < Motif
    
    ROOT_NOTE = 72
    PATTERN = [TICKS_8N, TICKS_16N, TICKS_16N]
    DESCENDING_NOTES = [0, -1, -1, -3, -3, -7, -10, -11]
    
    # set up a note to play faster & faster
    # 
    def generate_gesture(now, player_options = {})
      Gesture.new(Motif::next_beat(now)) do |gesture|
        event_time = 0
        accent = true
        desc_by = 0

        PATTERN.each do |dur|
          gesture.make :note, :at => event_time, :data => {
            :pitch => !@options[:notes].nil? ?
              @options[:notes][rand @options[:notes].size] :
              ROOT_NOTE + DESCENDING_NOTES[desc_by],
            :velocity => accent ? 100 : 20,
            :duration => dur
          }
          
          accent = false
          event_time += dur
          desc_by += rand 3
        end
      end
    end
    
  end
end
