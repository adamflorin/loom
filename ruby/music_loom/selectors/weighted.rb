# 
#  weighted.rb: select a motif based on static or dynamic weights
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Selectors
    module Weighted
      
      # simple weighted probability to decide which gesture comes next
      # 
      def select_motif
        # init_fancy_weights
        
        next_motif_class = nil
        total_weight = @motifs.map{|g| g[:weight]}.sum
        lucky_number = rand total_weight
        this_motif_max = 0
        options = {}
        
        @motifs.each do |motif|
          this_motif_max += motif[:weight]
          if lucky_number < this_motif_max
            next_motif_class = motif[:class]
            
            # FIXME: ignoring :options, using :parameters!
            options = motif[:parameters] || {}
            break
          end
        end
        
        return next_motif_class.nil? ? nil : next_motif_class.new(options)
      end
      
      # "fancy" = tied to globals. This code is on the chopping block
      # since Live has its own ways of shifting params based on others!
      # 
      def init_fancy_weights
        has_fancy_weights = !@motifs.select{|g| g.has_key? :weight_param}.size.zero?
        
        # list uses fancy weights. well, give each motif a concrete weight!
        if has_fancy_weights
          @motifs.each do |motif|
            global_param = motif[:weight_param].keys.first
            global_param_value = get_global(:environment).send(global_param)
            motif_probability_peak_at = motif[:weight_param][global_param]
            
            distance_from_peak = (global_param_value - motif_probability_peak_at).abs
            
            # overwrite motif weight
            motif[:weight] = (((1.0 - distance_from_peak) ** 4) * 100).to_i
          end
        end
      end
      
    end
  end
end
