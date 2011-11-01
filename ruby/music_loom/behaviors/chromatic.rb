# 
#  chromatic.rb: good ol' 12-tone equal temperament (MIDI notes)
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Behaviors
    module Chromatic
      
      attr_accessor :pitches
      
      # init
      # 
      def self.included(base)
        @pitches = []
        base.alias_method_chain :set_generator_parameter, :chromatic
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
      
    end
  end
end
