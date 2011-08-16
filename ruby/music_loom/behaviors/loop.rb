# 
#  loop.rb: looping behavior (store gesture history & iterate on it)
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Behaviors
    module Loop
      
      MAX_LOOP_LENGTH = 16
      
      attr_accessor :gesture_history, :gesture_history_index
      
      # init
      # 
      def self.included(base)
        base.alias_method_chain :populate_event_queue, :loop
        base.alias_method_chain :clear_events, :loop
        base.alias_method_chain :default_options, :loop
      end
      
      # 
      # 
      def default_options_with_loop
        default_options_without_loop.merge({
          :loop_on => 0, # false
          :loop_length => 4})
      end
      
      # 
      # 
      def clear_events_with_loop
        clear_events_without_loop
        
        @gesture_history = []
        @gesture_history_index = 0
      end
      
      # returns event array--might be new events or rescheduled (looped) old ones
      # 
      def populate_event_queue_with_loop(now)
        # if we're in loop mode and have a sufficient backlog
        if !@options[:loop_on].zero? and @gesture_history.size >= @options[:loop_length]

          # wrap index (loop_length may have changed earlier)
          @gesture_history_index = 0 if @gesture_history_index >= @options[:loop_length]

          # trim down history to just what we need (so it regenerates later) (?)
          @gesture_history.slice! 0, @gesture_history.size - @options[:loop_length]

          # find our place in the loop (index)
          play_index = @gesture_history_index + (@gesture_history.size - @options[:loop_length])

          # increment index
          @gesture_history_index += 1
          
          # grab event at that index, update it to now
          gesture = @gesture_history[play_index]
          gesture.start_time = gesture.new_now(now)
          
          return gesture

        # we need to generate some event lists
        else
          
          gesture = populate_event_queue_without_loop(now)

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
