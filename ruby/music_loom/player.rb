# 
#  player.rb: base class for repertoires (collections of gestures)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Player
    
    attr_accessor :gestures, :focal_point, :event_queue, :gesture_options, :option_means
    
    
    # # CONSTANTS
    # #
    
    DENSITY_COEFF = 10
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      # @gestures = []
      @event_queue = []
      @option_means = {}
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
          
          focus = calc_focus
          
          # now generate random options
          generate_gesture_options(focus)
          
          # volume is a factor of focus + global intensity
          @gesture_options[:volume] = focus * get_global(:atmosphere).intensity.constrain(0.1..1.0)
          
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
      @option_means[key] = value
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
      
      # create gesture_options from @option_means
      # 
      # generate a target value, then shoot toward it.
      # player deviance is based on global & focus.
      # 
      # low deviance = stay where you are. high deviance = go crazy!
      # 
      def generate_gesture_options(focus)
        player_deviance = get_global(:atmosphere).deviance * focus
        
        stddev = player_deviance / 4.0
        
        @option_means.each do |key, mean|
          # just do gaussian math for floats (i.e., means)
          if mean.is_a? Float
            target = MusicLoom::gaussian_rand(mean, stddev).constrain(0.0..2.0)
          
            # (init on first run)
            @gesture_options[key] ||= target
          
            # shoot toward target
            @gesture_options[key] += (target - @gesture_options[key]) * player_deviance
          else
            # just pass the data along otherwise (?)
            @gesture_options[key] = mean
          end
        end
      end
      
      # returns distance as 0. - 1. (= player "focus")
      # 
      def calc_focus
        MusicLoom::spotlight_focus(@focal_point)
      end
      
      # 
      # 
      def build_event(event)
        ["event", event].flatten
      end
      
  end
end
