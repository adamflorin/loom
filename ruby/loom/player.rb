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

        # dispatch all events
        # 
        @event_queue.each do |event|
          if event.at > now
            Loom::Max::dispatch(event)
          else
            Loom::logger.warn "Dropping event scheduled at #{event.at}. (It is now #{now}.)"
          end
        end.clear
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
            generator = self.send(set_method, Generator.new)
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

    end
  end
end
