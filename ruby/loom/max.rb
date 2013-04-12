# 
# dispatch.rb: schedule events in Max
# 
# Copyright 2013, Adam Florin. All rights reserved.
# 

module Loom
  module Max
    class << self

      # 
      # 
      def init
        init_tooltips
      end

      # 
      # 
      def init_tooltips
        inlet_assist('check in (bang)')
        outlet_assist('event out (list)', 'status (loaded, error)')
      end

    end
  end
end
