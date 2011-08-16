# 
#  decay.rb: like inertia for a player, slowly draining velocity
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Behaviors
    module Decay
      
      DECAY_RATE = 0.5
      
      #
      # 
      def self.included(base)
        base.alias_method_chain :check_in, :decay
        base.alias_method_chain :set_velocity, :decay
        base.alias_method_chain :populate_event_queue, :decay
        base.alias_method_chain :build_event, :decay
        
        # does this matter? or do we depend on set_velocity being called?
        # @motif_options[:decay] = 1.0
      end
      
      # apply a bit of decay on every check_in
      # 
      def check_in_with_decay(now)
        @motif_options[:decay] = (@motif_options[:decay] + get_global(:environment).decay_rate).constrain(0.0..1.27)
        
        check_in_without_decay(now)
      end
      
      # on impulse from user, bump decay back up
      # 
      def set_velocity_with_decay(velocity)
        @motif_options[:decay] = velocity / 100.0
        
        set_velocity_without_decay(velocity)
      end
      
      
      private
      
        # when decay goes below a threshold (zero), don't produce any new events.
        # 
        def populate_event_queue_with_decay(now)
          return ["stop"] if @motif_options[:decay] <= 0
        
          populate_event_queue_without_decay(now)
        end
        
        # apply decay to velocity
        # 
        def build_event_with_decay(event)
          out_event = event.clone
          
          if out_event[1][0] == "note"
            out_event[1][2] = (out_event[1][2] * @motif_options[:decay]).to_i.constrain(0..127)
          end
          
          build_event_without_decay(out_event)
        end
        
    end
  end
end
