# 
#  pattern.rb: rhythmic pattern
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Player
    module Pattern
      
      include Loom::Tools::Timing
            
      attr_accessor :steps, :timescale, :accent_on
      
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
          base.alias_method_chain :make_event, :pattern
        end
        
        # multiple events (per # steps)
        # 
        # FIXME: don't just totally overwrite what was there...!
        # 
        def generate_with_pattern
          event_time = 0
          event = nil
          rate = generate_rate
          num_steps = @player.steps.generate.to_i.constrain(1..16)
          accent_on = (@player.accent_on.generate * (num_steps-1)).to_i
          
          # iterator to make events (# steps)
          num_steps.times do |i|
                        
            # make individual event, set duration
            event = make_event :note, :at => event_time, :options => {
              num_steps => num_steps,
              :step_num => i,
              :accent => accent_on == i
            }, :data => {
              :duration => rate
            }
            event_time = event.end_at
          end

          make_event :done, :at => event_time
          
          return self
        end
        
        def make_event_with_pattern(event_type, event_data = {})
          if event_type == :note
            event_data[:data] ||= {}
            event_data[:data][:velocity] = event_data[:options][:accent] ? 120 : 40
          end

          make_event_without_pattern(event_type, event_data)
        end
        
        
        private
        
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
