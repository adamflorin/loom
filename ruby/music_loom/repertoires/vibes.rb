# 
#  string_thing.rb: for use with Tension string physical modeler
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Vibes < Repertoire
    
    def initialize
      @gestures = [
        # {:class => Pump, :weight => 10}]
        {:class => Pumpernickel, :weight => 10}]
      super
    end
    
  end
end
