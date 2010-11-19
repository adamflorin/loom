# 
#  tonality.rb: ratio-based tuning
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
require "yaml"

module MusicLoom
  module Tonality
    
    CONFIG_DIR = File.join(File.dirname(__FILE__), '..', '..', 'config')
    
    # tune the world to C
    BASE_PITCH = 60
    
    attr :scales, :scale_id
    
    
    # Just load up the array of ratios for the current scale,
    # all as float (never strings)
    # 
    def scale_ratios
      @scales[@scale_id.to_s].map{|p| (p.is_a? String) ? eval(p) : p}
    end
    
    # For now, just round to nearest scalar tone
    # 
    # TODO: variable amount of gravity toward nearest_scale_ratio,
    # Gaussian distribution around it (?)
    # 
    def fit_to_scale(rough_ratio)
      nearest_scale_ratio = if rough_ratio > 0
        rough_tonic = 2 ** (Math.log(rough_ratio) / Math.log(2)).floor
      
        ratios_and_deltas = scale_ratios.map do |scale_ratio|
        
          # bring scale_ratio into rough_ratio's 8ve
          scale_ratio *= 2 while scale_ratio < rough_tonic
          scale_ratio /= 2 while scale_ratio > (rough_tonic * 2)
        
          delta = (rough_ratio - scale_ratio).abs
          {:scale_ratio => scale_ratio, :delta => delta}
        end
      
        nearest_scale_ratio = ratios_and_deltas.sort{|x, y| x[:delta] <=> y[:delta]}.first[:scale_ratio]
      else
        nearest_scale_ratio = 0
      end
      return nearest_scale_ratio
    end
    
    
    private
      
      def load_scales
        @scales = {}
    
        @scales.update(YAML.load(File.read("#{CONFIG_DIR}/scales.yml")))
      end
      
  end
end
