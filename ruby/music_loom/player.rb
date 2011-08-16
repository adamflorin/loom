# 
#  player.rb: base class for players which generate gestures from motifs
#  and interact with one another
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Player
    
    DECAY_RATE = 0.5
    
    attr_accessor :motifs, :focal_point, :event_queue, :motif_options, :option_means,
      :options,
      :neighbors,
      :do_decay # start teasing out behaviors
    
    # can be extended by behaviors
    # 
    def default_options
      {}
    end
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      # @motifs = []
      
      # player options from max
      @options = default_options
      
      # motif options (& means)
      @option_means = {}
      @motif_options = {
        :decay => 1.0
      }
      
      @do_decay ||= true if @do_decay.nil?
      
      clear_events
    end
    
    # Check in: listen to what's going on & decide whether or not
    # to generate a gesture
    # 
    def check_in(now)
      
      # no events in the queue--either generate new gesture or loop old one
      if @event_queue.empty?
        
        # TODO: if decay is too low, just die
        if @do_decay and (@motif_options[:decay] <= 0)

          return ["stop"]
        end
        
        @event_queue = populate_event_queue(now)
      end
      
      # TODO: tidy up normalization of global decay
      if @do_decay
        @motif_options[:decay] = (@motif_options[:decay] + get_global(:environment).decay_rate).constrain(0.0..1.27)
      end
      
      return build_event(next_event(now))
    end
    
    # on init & stop
    # 
    def clear_events
      @event_queue = []
    end
    
    def set_motif_option(key, value)
      @option_means[key] = value
    end
    
    def set_player_option(key, value)
      @options[key] = value
    end
    
    # environment now hooks back in to tell players about their neighbors
    # 
    def register_neighbors(neighbors)
      @neighbors = neighbors
    end
    
    # on impulse
    # 
    def set_velocity(velocity)
      if @do_decay
        @motif_options[:decay] = velocity / 100.0
      end
    end
    
    
    private
      
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
      
      # just generate some events
      # 
      def populate_event_queue(now)
        gesture_events, start_time = generate_gesture_events(now)

        # TODO: notify neighbors that we output an event.
        # This doesn't work because our references to other players are incomplete (?)
        # @neighbors.each do |player|
        #   # player.check_in(now)
        # end

        return gesture_events
      end
      
      # generate events from gesture
      # 
      def generate_gesture_events(now)
        next_motif = select_motif
        
        focus = calc_focus
        
        # now generate random options
        generate_motif_options(focus)
        
        # volume is a factor of focus + global intensity
        # FIXME:TEMP--drop volume calc
        @motif_options[:volume] = 1.0 #focus * get_global(:environment).intensity.constrain(0.1..1.0)
        
        return next_motif.generate_events(now, @motif_options)
      end
      
      # simple weighted probability to decide which gesture comes next
      # 
      def select_motif
        next_motif_class = nil
        
        has_fancy_weights = !@motifs.select{|g| g.has_key? :weight_param}.size.zero?
        
        # list uses fancy weights. well, give each motif a concrete weight!
        if has_fancy_weights
          @motifs.each do |motif|
            global_param = motif[:weight_param].keys.first
            global_param_value = get_global(:environment).send(global_param)
            motif_probability_peak_at = motif[:weight_param][global_param]
            
            distance_from_peak = (global_param_value - motif_probability_peak_at).abs
            
            # overwrite motif weight
            motif[:weight] = (((1.0 - distance_from_peak) ** 4) * 100).to_i
          end
        end
        
        total_weight = @motifs.map{|g| g[:weight]}.sum
        lucky_number = rand total_weight
        this_motif_max = 0
        options = {}
        
        @motifs.each do |motif|
          this_motif_max += motif[:weight]
          if lucky_number < this_motif_max
            next_motif_class = motif[:class]
            options = motif[:options] || {}
            break
          end
        end
        
        return next_motif_class.new(options)
      end
      
      # create motif_options from @option_means
      # 
      # generate a target value, then shoot toward it.
      # player deviance is based on global & focus.
      # 
      # low deviance = stay where you are. high deviance = go crazy!
      # 
      def generate_motif_options(focus)
        player_deviance = get_global(:environment).deviance * focus
        
        stddev = player_deviance / 4.0
        
        @option_means.each do |key, mean|
          # just do gaussian math for floats (i.e., means)
          if mean.is_a? Float
            target = MusicLoom::gaussian_rand(mean, stddev).constrain(0.0..2.0)
          
            # (init on first run)
            @motif_options[key] ||= target
          
            # shoot toward target
            @motif_options[key] += (target - @motif_options[key]) * player_deviance
          else
            # just pass the data along otherwise (?)
            @motif_options[key] = mean
          end
        end
      end
      
      # take an event queue and bump up all times according to a delta
      # 
      # must sanitize 'now' in case scheduler has slipped?
      # 
      def repeat_events(gesture_events, now)
        # sanitize 'now'... may be earlier or later
        fixed_now = Motif::nearest_beat(now, gesture_events.first[0]).ceil
        
        return gesture_events.map do |event|
          [event[0] + fixed_now] + event[1..event.size]
        end
      end
      
      # DISABLED FOR SOUNDAFFECTS--
      # just let distance always be zero for now!
      # 
      # returns distance as 0. - 1. (= player "focus")
      # 
      def calc_focus
        0.0 #MusicLoom::spotlight_focus(@focal_point)
      end
      
      # 
      # 
      def build_event(event)
        out_event = event.clone
        
        # apply decay
        if @do_decay
          if out_event[1][0] == "note"
            out_event[1][2] = (out_event[1][2] * @motif_options[:decay]).to_i.constrain(0..127)
          end
        end
        
        ["event", out_event].flatten
      end
      
  end
end
