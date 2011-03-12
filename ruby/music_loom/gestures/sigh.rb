# 
#  sigh.rb: descending arcs
#  
#  Copyright March 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Sigh < Gesture
    
    DEFAULT_OPTIONS = {
      :portamento_dur => TICKS_1N,
      
      :bend_down_ratio => 0.9
    }
    
    # 
    # 
    def generate_events(now, player_options = {})
      # init
      options = DEFAULT_OPTIONS.merge player_options
      events = []
      
      # every 4 beats ISH
      start_time = Gesture::next_beat(now, TICKS_1N) + ((rand 4) * TICKS_4N)
      event_time = start_time
            
      dur = TICKS_1N * 2
      velocity = 100
      
      # 1.0 ± 1.0
      start_ratio = (rand 20) / 10.0
      
      # down
      end_ratio = start_ratio * options[:bend_down_ratio]
      
      # fit_to_scale
      start_ratio = get_global(:atmosphere).fit_to_scale(start_ratio)
      end_ratio = get_global(:atmosphere).fit_to_scale(end_ratio)
      
      # two bend events: go straight to pitch, then bend down
      events << [event_time, ["bend", ratio_to_pitch_bend(start_ratio)]]
      events << [event_time, ["bend", ratio_to_pitch_bend(end_ratio), options[:portamento_dur]]]
      
      events << [event_time, ["note", Tonality::BASE_PITCH, velocity, dur]]
      
      return events, start_time
    end
    
  end
end
