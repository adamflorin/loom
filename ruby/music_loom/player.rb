# 
#  player.rb: base class for players which generate gestures
#  and interact with one another
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

module MusicLoom
  class Player
    
    attr_accessor :event_queue
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      clear_events
    end
    
    # output the next event in the queue, generating a gesture
    # if necessary.
    # 
    def check_in(now)
      
      # no events in the queue--either generate new gesture or loop old one
      if @event_queue.empty?
        
        gesture = make_gesture(now)
        
        @event_queue = gesture.output_events
      end
      
      return build_event(next_event(now))
    end
    
    # on init & stop
    # 
    def clear_events
      @event_queue = []
    end
    
    # setter
    # 
    # TODO: what if player does not have attribute for generator?
    # 
    def set_generator_parameter(key, parameter)
      base_key = Generator.base_key(key)
      
      if (generator = generator(base_key)).nil?
        generator = self.send("#{base_key}=", Generator.new)
      end
      
      generator.set_parameter(key, parameter)
    end
    
    # getter
    # 
    def generator(base_key)
      self.send(base_key)
    rescue NoMethodError
      # let nil be returned
    end
    
    
    private
      
      # generate a gesture (which contains events)
      # 
      def make_gesture(now)
        Gesture.new(Motif::next_beat(now)) do |gesture|
          event = make_event(gesture, 0)
          gesture.make :done, :at => event.end_at
        end
      end
      
      # # make N events (1 by default), return end time of last event.
      # # 
      # def make_events(gesture, event_time = 0)
      #   event = make_event(gesture, event_time)
      #   return event.end_at
      # end
      
      # make a single event, return it.
      # 
      def make_event(gesture, event_time)
        gesture.make :note, :at => event_time
      end
      
      # get next event off the queue,
      # do a sanity check to make sure we're not behind schedule--
      # if we are, just fake like we're not (but output an error).
      # 
      def next_event(now)
        out_event = @event_queue.shift unless @event_queue.empty?

        # check if the event we're sending out is in the past or is close to it (!)
        if !out_event.nil? and (out_event.at < now)
          error "TIMER FAIL! Event's scheduled at #{out_event.at} but it's already #{now}!"

          # try to get back on track. This seems to work...?
          out_event.at = now.ceil + 1 # enough?
        end

        return out_event
      end
      
      # 
      # 
      def build_event(event)
        event.output.flatten
      end
      
  end
end
