# 
#  loop.rb: looping behavior (store gesture history & iterate on it)
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Player
    module Loop
      
      MAX_LOOP_LENGTH = 16
      
      attr_accessor :loop_on, :loop_len
      attr_accessor :gesture_history, :gesture_history_index
      
      # init
      # 
      def self.included(base)
        base.alias_method_chain :set_generator_parameter, :loop
        base.alias_method_chain :clear_events, :loop
        base.alias_method_chain :generate_gesture, :loop
      end
      
      # intercept "loop_on" param
      # 
      def set_generator_parameter_with_loop(key, parameter)
        if key != :loop_on
          set_generator_parameter_without_loop(key, parameter)
        else
          @loop_on = (parameter.first == 1.0)
        end
      end
      
      # 
      # 
      def init_loop
        @gesture_history = []
        @gesture_history_index = 0
      end
      
      # 
      # 
      def clear_events_with_loop
        clear_events_without_loop
        
        init_loop
      end
      
      # returns event array--might be new events or rescheduled (looped) old ones
      # 
      def generate_gesture_with_loop(now)
        loop_len = @loop_len.generate.to_i.constrain(1..16)
        
        # if it was dropped in while playing
        init_loop if @gesture_history.nil?
        
        # if we're in loop mode and have a sufficient backlog
        if @loop_on and @gesture_history.size >= loop_len

          # wrap index (loop_len may have changed earlier)
          @gesture_history_index = 0 if @gesture_history_index >= loop_len

          # trim down history to just what we need (so it regenerates later) (?)
          @gesture_history.slice! 0, @gesture_history.size - loop_len

          # find our place in the loop (index)
          play_index = @gesture_history_index + (@gesture_history.size - loop_len)

          # increment index
          @gesture_history_index += 1
          
          # grab event at that index, update it to now
          gesture = @gesture_history[play_index]
          gesture.start_time = gesture.new_now(now)
          
          return gesture

        # we need to generate some event lists
        else
          
          gesture = generate_gesture_without_loop(now)
          
          # push gesture events onto sequence.
          # ALWAYS track whatever we just did, in case we decide to do it again.
          @gesture_history << gesture

          # memory mngmt: trim oldest event lists off
          @gesture_history.shift if @gesture_history.size > MAX_LOOP_LENGTH

          # now assign events to queue so they'll get played
          return gesture
        end
      end
      
    end
  end
end
