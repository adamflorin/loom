# 
#  syncopation.rb: ease notes off the downbeats, in tuplets or with offsets
#  
#  Copyright November 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Player
    module Syncopation
      
      # because enum'd live.dials only output the INDEX of the dial! silly!
      TIMESCALE_VALUES = [1.0/64, 1.0/32, 1.0/16, 1.0/8, 1.0/4, 1.0/2, 1.0]
      
      # attr_accessor :tupletize, :weak_ratio
      attr_accessor :weak_dur
      
      def self.included(base)
        Gesture.send :include, GestureMethods
      end
      
      
      module GestureMethods
        
        def self.included(base)
          base.alias_method_chain :make_event, :syncopation
        end
        
        # set note duration
        # 
        def make_event_with_syncopation(event_type, event_data = {})
          if event_type == :note
            event_data[:data] ||= {}
            event_data[:data][:duration] = syncopate(event_data[:data], event_data[:options])
          end

          make_event_without_syncopation(event_type, event_data)
        end
        
        
        private
          
          # returns new event time
          # 
          def syncopate(event_data, options = {})
            is_weak = (!options[:accent].nil? and !options[:accent])
            weak_coef = TIMESCALE_VALUES[@player.weak_dur.generate]
            return event_data[:duration] * (is_weak ? weak_coef : 1.0)
          end
          
      end
      
    end
  end
end
