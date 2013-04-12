# 
#  player.rb: base class for players which generate gestures
#  and interact with one another
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

module Loom
  module Player
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
        
        # because float precision triggers TIMER FAILs
        now = now.ceil

        # from the top
        clear_events if (now <= 0)
        
        # generate new gesture if we don't have one to output
        if @event_queue.empty?

          gesture = generate_gesture(now)

          @event_queue = gesture.output_events
        end

        return build_event(next_event(now))
      end
      
      # 
      # 
      def generate_gesture(now)
        Gesture.new(now, self).generate
      end
      
      # on init & stop
      # 
      def clear_events
        @event_queue = []
      end
      
      def load_module(module_name)
        module_to_load = Loom::Player.const_get(module_name.to_s.camelize)

        if self.class.ancestors.include? module_to_load
          raise "Cannot include same behavior twice!"
        end

        # mix in
        self.class.send(:include, module_to_load)
      end
      
      # setter
      # 
      def set_generator_parameter(key, parameter)
        base_key = Generator.base_key(key)
        set_method = "#{base_key}="

        if self.respond_to? set_method
          if (generator = generator(base_key)).nil?
            generator = self.send("#{base_key}=", Generator.new)
          end

          generator.set_parameter(key, parameter)
        else
          Loom::logger.warn "Behavior does not have parameter #{base_key}."
        end
      end

      # getter
      # 
      def generator(base_key)
        self.send(base_key)
      rescue NoMethodError
        # let nil be returned
      end


      private

        # get next event off the queue,
        # do a sanity check to make sure we're not behind schedule--
        # if we are, just fake like we're not (but output an error).
        # 
        def next_event(now)
          out_event = @event_queue.shift unless @event_queue.empty?
          
          # check if the event we're sending out is in the past or is close to it (!)
          if !out_event.nil? and (out_event.at < now)
            Loom::logger.warn "Event's scheduled at #{out_event.at} but it's already #{now}."

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
end
