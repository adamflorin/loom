# 
#  note.rb: MIDI note event
#  
#  Copyright August 2011, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Event
    
    class Note < Event
      
      DEFAULT_DATA = {
        :pitch => 60,
        :velocity => 100,
        :duration => Motif::TICKS_4N
      }
      
      def initialize(args = {})
        # must clone or all note events will point to same structure!
        @data = DEFAULT_DATA.clone
        
        super(args)

      end
      
      # serialize pitch event into format Max makenote wants
      # 
      def output(data = nil)
        super([@data[:pitch], @data[:velocity], @data[:duration]])
      end
      
    end
    
  end
end
