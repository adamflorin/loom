# 
#  gesture.rb: group of events with an offset time
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Gesture
    
    attr_accessor :events, :start_time
    
    # TODO: args to pass thru to next_beat
    # 
    def initialize(now, &block)
      @events = []
      @start_time = Motif::next_beat(now).ceil
      yield self if block_given?
    end
    
    # create a new event
    # 
    def make(event_type, event_data = {})
      event_class = Event.const_get(event_type.to_s.camelize)
      @events << event_class.new(event_data)
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
    
    # must sanitize 'now' in case scheduler has slipped?
    # "may be earlier or later"?
    # 
    def new_now(now)
      Motif::nearest_beat(now, @events.first.at).ceil
    end
    
  end
end
