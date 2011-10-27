# 
#  player.rb: base class for players which generate gestures from motifs
#  and interact with one another
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Player
    
    # default selector
    include Selectors::Weighted
    
    attr_accessor :motifs, :options, :event_queue
    
    # can be extended by behaviors
    # 
    def default_options
      {}
    end
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      @motifs = []
      
      # player options from max
      @options = default_options
      
      clear_events
    end
    
    # output the next event in the queue, generating a gesture
    # from a motif if necessary.
    # 
    def check_in(now)
      
      # no events in the queue--either generate new gesture or loop old one
      if @event_queue.empty?
        
        gesture = generate_gesture(now)
        
        @event_queue = gesture.output_events
      end
      
      return build_event(next_event(now))
    end
    
    # on init & stop
    # 
    def clear_events
      @event_queue = []
    end
    
    # These are typically behavior parameters (?)
    # 
    def set_player_option(key, value)
      @options[key] = value
    end
        
    # Motif mgmt.
    # 
    def add_motif(device_id, motif_class_name)
      motif_class = MusicLoom.const_get(motif_class_name.to_s.camelize)
      @motifs << motif_class.new(device_id)
    end
    
    # Motif mgmt.
    # 
    def remove_motif(device_id)
      @motifs.delete_if do |motif|
        motif.device_id == device_id
      end
    end
    
    # Motif mgmt.
    # 
    def get_motif(device_id)
      @motifs.select do |motif|
        motif.device_id == device_id
      end.first
    end
    
    
    private
      
      # generate events from gesture
      # 
      def generate_gesture(now)
        next_motif = select_motif
        
        return Motif::rest(now) if next_motif.nil?
        
        return next_motif.generate_gesture(now)
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
