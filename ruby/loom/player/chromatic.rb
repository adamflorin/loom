# 
#  chromatic.rb: good ol' 12-tone equal temperament (MIDI notes)
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 
module Loom
  module Player
    module Chromatic
      
      attr_accessor :pitches, :min_pitch, :max_pitch, :pitch_pos
      
      # init
      # 
      def self.included(base)
        base.alias_method_chain :set_generator_parameter, :chromatic
        Gesture.send :include, GestureMethods
      end
      
      # intercept "pitches" param
      # 
      # strip meaningless -1, which is just there so that the
      # [pattr]'s list is never empty... we do lots of legwork
      # here because [kslider] doesn't store its state. (!!!)
      # 
      # TODO: make a general before_filter for handling special params like this?
      # 
      def set_generator_parameter_with_chromatic(key, parameter)
        if key != :pitches
          set_generator_parameter_without_chromatic(key, parameter)
        else
          @pitches = parameter.sort - [-1]
        end
      end
      
      # Loaded into Gesture, not Player
      # 
      module GestureMethods
        
        def self.included(base)
          base.alias_method_chain :make_event, :chromatic
        end
        
        # set note pitch
        # 
        def make_event_with_chromatic(event_type, event_data = {})
          if event_type == :note and !@player.pitches.empty?
            event_data[:data] ||= {}
            event_data[:data][:pitch] = generate_pitch
          end

          make_event_without_chromatic(event_type, event_data)
        end
        
        
        private
          
          # while pitch_pos moves in undifferentiated pitch space,
          # we fit it to the given (chromatic) scale in a given range.
          # 
          def generate_pitch
            # range
            bounds = [@player.min_pitch.generate, @player.max_pitch.generate]
            
            # desired "normalized" (no 8ve offset) pitch
            position = @player.pitch_pos.generate.constrain(0..1)
            desired = (position * (bounds.max - bounds.min) + bounds.min).round
            octave_offset = (desired / 12).floor.to_i
            desired_normal = desired - octave_offset * 12
            
            # nearest normal pitch
            nearest_normal = @player.pitches.sort do |px, py|
              (px - desired_normal).abs <=> (py - desired_normal).abs
            end.first
            
            # add 8ve offset back in
            return nearest_normal + octave_offset * 12
          end
          
      end
      
    end
  end
end
