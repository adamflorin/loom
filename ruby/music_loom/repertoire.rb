# 
#  gesture.rb: base class for repertoires (collections of gestures)
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Repertoire
    
    attr_accessor :gestures, :event_queue
    
    # set up gestures. for subclasses to overwrite
    # 
    def initialize
      # @gestures = []
      @event_queue = []
    end
    
    # get next event, generating some if necessary
    # 
    # now - in ticks (480 / 4n)
    # 
    def next_event(now)
      
      # no events... chose a gesture and create some!
      if @event_queue.empty?
        current_gesture_class = @gestures[rand(@gestures.length)]
        current_gesture = current_gesture_class.new
        @event_queue = current_gesture.generate_events(now)
      end
      
      # TODO: if there are multiple events at the same time...
      # what to do? Need more Max logic to tease them apart.

      return ["event", @event_queue.shift].flatten
    end
    
    # 
    # 
    def clear_events
      @event_queue = []
    end
    
  end
end
