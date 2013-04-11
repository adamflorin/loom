# 
#  event.rb: simple struct for MIDI events
# 
#  tbd: always store events in canonical form?
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Event
    
    class Event
      
      include Loom::Tools::Timing
      include Loom::Tools::Tonality
      
      attr_accessor :at, :data
      
      # init from args
      # 
      def initialize(args = {})
        # must clone or all note events will point to same structure!
        @data ||= default_data.clone
        
        args.each do |k, v|
          self.send("#{k}=", v) unless v.nil?
        end
      end
      
      # 
      # 
      def data=(data)
        @data.merge! data if data.is_a? Hash
      end

      # for schedule-event patcher
      # 
      def to_patcherargs
        [:at, :event].map do |attr|
          ["@#{attr}", self.send(attr)]
        end.flatten
      end

      # convert event data into array form for output into Max world.
      # 
      # allow subclasses to specify data.
      # 
      def event(data = nil)
        [type] + (data || [])
      end

      # 
      # 
      def end_at
        @at + @data[:duration]
      end
      
      # introspection. returns string for [route].
      # 
      def type
        self.class.name.gsub(/[^:]+$/).first.underscorize
      end
      
      private
        
        # to be overwritten
        # 
        def default_data
          {}
        end
        
    end
    
  end
end
