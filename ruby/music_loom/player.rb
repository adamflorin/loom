# 
#  player.rb: base class for repertoires (collections of gestures)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Player
    
    attr_accessor :gestures, :focal_point, :event_queue, :gesture_options
    
    
    # # CONSTANTS
    # #
    
    DENSITY_COEFF = 10
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      # @gestures = []
      @event_queue = []
      @gesture_options = {}
    end
    
    # Check in: listen to what's going on & decide whether or not
    # to generate a gesture
    # 
    def check_in(now)
      if @event_queue.empty?
        density_space = (1.0 - get_global(:atmosphere).density) * DENSITY_COEFF + 1
        
        if (rand density_space).zero?
          next_gesture = select_gesture
          
          # TODO: vary parameters more based on focus
          @gesture_options[:volume] = focus
          
          @event_queue = next_gesture.generate_events(now, @gesture_options)
        end
      end
      
      # TODO: aperiodic rest time? factor of density?
      return build_event(@event_queue.empty? ? Gesture.rest(now) : next_event(now))
    end
    
    # get next event off the queue,
    # do a sanity check to make sure we're not behind schedule--
    # if we are, just fake like we're not.
    # 
    def next_event(now)
      out_event = @event_queue.shift unless @event_queue.empty?
      
      # check if the event we're sending out is in the past or is close to it (!)
      if !out_event.nil? and (out_event[0] < now)
        error "TIMER FAIL! Event's scheduled at #{out_event[0]} but it's already #{now}!"
        
        # try to get back on track. This seems to work...?
        out_event[0] = now.ceil + 1 # enough?
      end
      
      return out_event
    end
    
    # 
    # 
    def clear_events
      @event_queue = []
    end
    
    def set_gesture_option(key, value)
      @gesture_options[key] = value
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
      
      # returns distance as 0. - 1. (= player "focus")
      # 
      def focus
        # get radial distance (max 0.5)
        distance = [(@focal_point - get_global(:atmosphere).spotlight).abs, 0.5].min
        
        return 1.0 - distance * 2.0
      end
      
      # 
      # 
      def build_event(event)
        ["event", event].flatten
      end
      
  end
end
