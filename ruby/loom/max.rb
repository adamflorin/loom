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
        init_handles
        init_tooltips

        # TODO: create "done" event at time 0
      end

      # 
      # 
      def init_handles
        $patcher ||= max_object.getParentPatcher
        $out_box ||= $patcher.getNamedBox "dispatch_events"
      end

      # 
      # 
      def init_tooltips
        inlet_assist('check in (bang)')
        outlet_assist('event out (list)', 'status (loaded, error)')
      end

      # Schedule event using a patcher with [timepoint]
      # 
      def dispatch(event)
        Loom::logger.debug "Dispatching event #{event.event} at #{event.at}."

        box_rect = get_box_rect

        # create box with args
        box = $patcher.newDefault(
          0,
          0,
          "schedule-event",
          $max_ruby_adapter.toAtoms(event.to_patcherargs))

        # connect it to output
        $patcher.connect box, 0, $out_box, 0
      end


      private

        def get_box_rect
          left, top, right, bottom = max_object.getMaxBox.getRect
          {left: left, top: top, right: right, bottom: bottom}
        end

    end
  end
end
