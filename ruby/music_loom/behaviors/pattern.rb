# 
#  pattern.rb: rhythmic pattern
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Behaviors
    module Pattern
      
      attr_accessor :steps, :timescale
      
      # because enum'd live.dials only output the INDEX of the dial! silly!
      TIMESCALE_VALUES = [Motif::TICKS_64N, Motif::TICKS_32N, Motif::TICKS_16N, Motif::TICKS_8N, Motif::TICKS_4N, Motif::TICKS_2N, Motif::TICKS_1N]    
      
      # 
      # 
      def self.included(base)
        base.alias_method_chain :make_event, :pattern
      end
      
      # multiple events (per # steps)
      # 
      # only returns LAST event for make_gesture
      # 
      def make_event_with_pattern(gesture, event_time)
        event = nil
        rate = generate_rate
        num_steps = @steps.generate.to_i.constrain(0..16)
        
        # iterator to make events (# steps)
        num_steps.times do |i|
          # make individual event, set duration
          event = make_event_without_pattern(gesture, event_time)
          event.data[:duration] = rate
          
          event_time += rate
        end
        
        return event
      end
      
      
      private
        
        # 
        # 
        def generate_rate
          timescale_index = @timescale.generate.round
          rate = TIMESCALE_VALUES[timescale_index.constrain(0..TIMESCALE_VALUES.size-1)]
        end
        
    end
  end
end
