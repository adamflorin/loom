# 
#  pump.rb: pump on 8ve
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Amphibrach < Gesture
    
    # # CONSTANTS
    # #
    
    STRESSES = [false, true, false]
    
    
    # # SCALES
    # # 
    
    # FIXME: pitches
    
    # set up a note to play faster & faster
    # 
    def generate_events(now, options = {})
      
      # RHYTHM options
      # 0. is strong short/long beats, 1.0 is triplets
      options[:swing_ratio] ||= 0.2 # 0. - 1.
      
      options[:time_scale] ||= 0.25 # time ratio (rounded to nearest power of 2)
      
      
      # TONALITY options
      options[:melody_offset] ||= 1.0 # pitch ratio
      
      options[:melody_arc] ||= 1.0 # pitch ratio
      
      options[:melody_angle] ||= 1.0 # pitch ratio
      
      options[:portamento_dur] ||= 0.0 # 0. - 1.
      
      
      events = []
      event_time = Gesture::next_beat(now) - TICKS_16N
      
      
      STRESSES.each_with_index do |stress, i|
        
        # ACCENT
        velocity = 40 + (stress ? 40 : 0) * (1.0 - options[:swing_ratio])
        
        
        # RHYTHM
        
        dur = stress ? TICKS_8N : TICKS_16N
        
        # morph from strong 4/4 accents to tuplet
        tuplet_dur = (TICKS_4N / STRESSES.size)
        dur += (tuplet_dur - dur) * options[:swing_ratio]
        
        dur *= round_to_power(options[:time_scale] * 4)
        
        
        # PITCH (BEND)
        
        # apply melody ARC
        bend_ratio = stress ? options[:melody_arc] : 1.0
        
        # apply melody ANGLE
        angle_amount = (i.to_f / (STRESSES.size - 1)) # 0. - 1.
        bend_ratio *= (options[:melody_angle] ** angle_amount)
        
        # apply melody OFFSET
        bend_ratio *= options[:melody_offset]
        
        # fit melody to SCALE
        bend_ratio = get_global(:atmosphere).fit_to_scale(bend_ratio)
        
        # output as pitch bend!
        pitch_bend = ratio_to_pitch_bend(bend_ratio)
        events << [event_time, ["bend", pitch_bend, dur * options[:portamento_dur]]]
        
        
        # => EVENT!
        
        events << [event_time, ["note", Tonality::BASE_PITCH, velocity, dur]]
        
        event_time += dur
        
      end
      
      # DONE event. if Player wants a longer pause, can just add another...?
      events << [event_time + 0, ["done"]]
    
      # NOTE! sorting events just in case they didn't end up that way...?
      return events.sort{|x, y| x[0] <=> y[0]}
    end
    
  end
end
