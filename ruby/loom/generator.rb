# 
#  generator.rb: description
#  
#  Copyright October 2011, Adam Florin. All rights reserved.
# 

module Loom
  class Generator
    
    attr_accessor :input, :last_output, :deviation, :inertia
    
    # All of a generator's inputs currently come in separately from Max
    # (because they're bound with [autopattr]), with a common base key
    # optionally followed by parameter key (inertia, deviation).
    # 
    def self.base_key(key)
      key.to_s.gsub(/_deviation|_inertia/, "")
    end
    
    # as above, map parameter keys to instance vars.
    # 
    def set_parameter(key, parameter)
      
      # parameter may be a splat or a single value
      parameter = parameter.first if parameter.is_a?(Array) and parameter.size == 1
      
      case key.to_s
      when /_deviation$/
        @deviation = parameter / 100.0
      when /_inertia$/
        @inertia = parameter / 100.0
      else
        @input = parameter
      end
    end
    
    # get output value, typically generating it (using "deviate")
    # 
    def generate(range = nil)
      if @input.is_a?(Float) and !!@deviation
        return @last_output = deviate(range)
      else
        return @input
      end
    end
    
    
    private
    
      # GENERATE a new output value based on (user-input) parameters
      # 
      # - @deviation: std. dev. for gaussian_rand
      # - @inertia: how quickly (or not) to jump to new rand value
      # 
      def deviate(range)
      
        # random but near(-ish) the value
        near_value = Loom::gaussian_rand(@input, @deviation)
        
        near_value = near_value.constrain(range) if range
        
        # first time this motif is being run
        @last_output ||= near_value
      
        return @last_output + (near_value - @last_output) * (1.0 - @inertia)
      end
    
  end
end
