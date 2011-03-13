# 
#  player.rb: base class for repertoires (collections of gestures)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Player
    
    attr_accessor :gestures, :focal_point, :event_queue, :gesture_options, :option_means,
      :gesture_history, :gesture_history_index,
      :options
    
    
    # # CONSTANTS
    # #
    
    DENSITY_COEFF = 10
    
    # SEQUENCE_LENGTH = 2
    # SEQUENCE_REPEATS = 4
    
    MAX_LOOP_LENGTH = 16
    
    DEFAULT_OPTIONS = {
      :loop_on => false,
      :loop_length => 4
    }
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      # @gestures = []
      
      # set by code
      @event_queue = []
      
      # player options from max
      @options = DEFAULT_OPTIONS
      
      # gesture options (& means)
      @option_means = {}
      @gesture_options = {}
      
      # looping
      @gesture_history = []
      
      @gesture_history_index = 0
    end
    
    # Check in: listen to what's going on & decide whether or not
    # to generate a gesture
    # 
    def check_in(now)
      if @event_queue.empty?
          
        # if we're in loop mode and have a sufficient backlog
        if !@options[:loop_on].zero? and @gesture_history.size >= @options[:loop_length]
          
          # wrap index (loop_length may have changed earlier)
          @gesture_history_index = 0 if @gesture_history_index >= @options[:loop_length]
          
          # trim down history to just what we need (so it regenerates later) (?)
          @gesture_history.slice! 0, @gesture_history.size - @options[:loop_length]
          
          # find our place in the loop (index)
          play_index = @gesture_history_index + (@gesture_history.size - @options[:loop_length])
          
          # grab event at that index, update it to now
          @event_queue = repeat_events(@gesture_history[play_index], now)
          
          # increment index
          @gesture_history_index += 1
          
        # we need to generate some event lists
        else
          
          # decide whether to generate an event or to rest
          density_space = (1.0 - get_global(:atmosphere).density) * DENSITY_COEFF + 1
          gesture_events, start_time = if (rand density_space).zero?
            
            # generate events
            generate_gesture_events(now)
          else
          
            # just put a rest on the queue
            [Gesture.rest(now)]
          end
          
          # subtract NOW from event times to make zero-based ("normalized") list
          normalized_gesture_events = gesture_events.map do |event|
            [event[0] - start_time] + event[1..event.size]
          end
          
          # push gesture events onto sequence.
          # ALWAYS track whatever we just did, in case we decide to do it again.
          @gesture_history << normalized_gesture_events
          
          # memory mngmt: trim oldest event lists off
          @gesture_history.shift if @gesture_history.size > MAX_LOOP_LENGTH
          
          # now assign events to queue so they'll get played
          @event_queue = gesture_events
        end
      end
      
      return build_event(next_event(now))
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
    
    def set_player_option(key, value)
      @options[key] = value
    end
    
    
    private
      
      # generate events from gesture
      # 
      def generate_gesture_events(now)
        next_gesture = select_gesture

        focus = calc_focus

        # now generate random options
        generate_gesture_options(focus)

        # volume is a factor of focus + global intensity
        @gesture_options[:volume] = focus * get_global(:atmosphere).intensity.constrain(0.1..1.0)

        return next_gesture.generate_events(now, @gesture_options)
      end
      
      # simple weighted probability to decide which gesture comes next
      # 
      def select_gesture
        next_gesture_class = nil
        total_weight = @gestures.map{|g| g[:weight]}.sum
        lucky_number = rand total_weight
        this_gesture_max = 0
        options = {}
        
        @gestures.each do |gesture|
          this_gesture_max += gesture[:weight]
          if lucky_number < this_gesture_max
            next_gesture_class = gesture[:class]
            options = gesture[:options] || {}
            break
          end
        end
        
        return next_gesture_class.new(options)
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
      
      # take an event queue and bump up all times according to a delta
      # 
      # must sanitize 'now' in case scheduler has slipped?
      # 
      def repeat_events(gesture_events, now)
        # sanitize 'now'... may be earlier or later
        fixed_now = Gesture::nearest_beat(now, gesture_events.first[0]).ceil
        
        return gesture_events.map do |event|
          [event[0] + fixed_now] + event[1..event.size]
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
