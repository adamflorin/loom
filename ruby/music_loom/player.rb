# 
#  player.rb: base class for repertoires (collections of gestures)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Player
    
    attr_accessor :gestures, :event_queue
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      # @gestures = []
      @event_queue = []
    end
    
    # Check in: listen to what's going on & decide whether or not
    # to generate a gesture
    # 
    def check_in(now)
      if @event_queue.empty?
        density_space = (1.0 - get_global(:atmosphere).density) * 10 + 1
        
        if (rand density_space).zero?
          next_gesture = select_gesture
          
          @event_queue = next_gesture.generate_events(now)
        end
      end
      
      # TODO: aperiodic rest time? factor of density?
      return build_event(@event_queue.empty? ? Gesture.rest(now) : next_event)
    end
    
    # get next event, generating some if necessary
    # 
    # now - in ticks (480 / 4n)
    # 
    def next_event
      @event_queue.shift unless @event_queue.empty?
    end
    
    # 
    # 
    def clear_events
      @event_queue = []
    end
    
    
    private
      
      # simple weighted probability to decide which gesture comes next
      # 
      def select_gesture
        next_gesture_class = nil
        total_weight = @gestures.map{|g| g[:weight]}.sum
        lucky_number = rand total_weight
        this_gesture_max = 0
        
        @gestures.each do |gesture|
          this_gesture_max += gesture[:weight]
          if lucky_number < this_gesture_max
            next_gesture_class = gesture[:class]
            break
          end
        end
        
        return next_gesture_class.new
      end
      
      # 
      # 
      def build_event(event)
        ["event", event].flatten
      end
      
  end
end
