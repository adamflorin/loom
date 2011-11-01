# 
#  gesture.rb: methods for producing gestures (which end up being
#  sequences of events) based on player "morphological" params.
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Gesture
    
    attr_accessor :events, :player, :start_time
    
    # init & generate
    # 
    def initialize(now, player)
      @events = []
      @start_time = Motif::next_beat(now)
      @player = player
      
      generate
    end
    
    # spit out time-adjusted event list
    # 
    def output_events
      @events.map do |event|
        adjusted_event = event.clone
        adjusted_event.at += @start_time
        adjusted_event
      end
    end
    
    
    private
      
      # default gesture
      # 
      def generate
        event = make_event :note, :at => 0
        make_event :done, :at => event.end_at
      end

      # build a new event
      # 
      def make_event(event_type, event_data = {})
        event_class = Event.const_get(event_type.to_s.camelize)
        @events << event_class.new(event_data)
        return @events.last
      end
      
      # must sanitize 'now' in case scheduler has slipped?
      # "may be earlier or later"?
      # 
      def new_now(now)
        Motif::nearest_beat(now, @events.first.at).ceil
      end
      
  end
end
