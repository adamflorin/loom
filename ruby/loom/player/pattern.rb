# 
#  pattern.rb: rhythmic pattern
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Player
    module Pattern
      
      include Loom::Tools::Timing
      
      attr_accessor :steps, :timescale
      
      # because enum'd live.dials only output the INDEX of the dial! silly!
      TIMESCALE_VALUES = [TICKS_64N, TICKS_32N, TICKS_16N, TICKS_8N, TICKS_4N, TICKS_2N, TICKS_1N]    
      
      # 
      # 
      def self.included(base)
        Gesture.send :include, GestureMethods
      end
      
      module GestureMethods
        
        def self.included(base)
          base.alias_method_chain :generate, :pattern
        end
        
        private
        
          # multiple events (per # steps)
          # 
          # FIXME: don't just totally overwrite what was there...!
          # 
          def generate_with_pattern
            event_time = 0
            event = nil
            rate = generate_rate
            num_steps = @player.steps.generate.to_i.constrain(1..16)

            # iterator to make events (# steps)
            num_steps.times do |i|
              # make individual event, set duration
              event = make_event :note, :at => event_time, :data => {
                :duration => rate
              }
              event_time += rate
            end

            make_event :done, :at => event.end_at
          end

          # 
          # 
          def generate_rate
            timescale_index = @player.timescale.generate.round
            rate = TIMESCALE_VALUES[timescale_index.constrain(0..TIMESCALE_VALUES.size-1)]
          end
          
      end
      
    end
  end
end
