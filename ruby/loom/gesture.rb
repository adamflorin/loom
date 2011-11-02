# 
#  gesture.rb: methods for producing gestures (which end up being
#  sequences of events) based on player "morphological" params.
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module Loom
  class Gesture
    
    extend Loom::Tools::Timing
    
    attr_accessor :events, :player, :start_time
    
    # init & generate
    # 
    def initialize(now, player = nil)
      @events = []
      @start_time = self.class.next_beat(now)
      @player = player
      
      yield self if block_given?
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
    
    # generate a rest, i.e. a silent gesture
    # 
    def self.rest(now)
      return self.new(next_beat(now)) do |gesture|
        gesture.make_event :done, :at => 0
      end
    end
    
    # default gesture
    # 
    def generate
      event = make_event :note, :at => 0
      make_event :done, :at => event.end_at
      return self
    end

    # build a new event
    # 
    def make_event(event_type, event_data = {})
      event_class = Event.const_get(event_type.to_s.camelize)
      @events << event_class.new(event_data)
      return @events.last
    end
    
    
    private
    
      # must sanitize 'now' in case scheduler has slipped?
      # "may be earlier or later"?
      # 
      def new_now(now)
        nearest_beat(now, @events.first.at).ceil
      end
      
  end
end
