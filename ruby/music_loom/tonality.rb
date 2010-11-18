# 
#  tonality.rb: ratio-based tuning
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  class Tonality
    
    class << self
       
      def method_name
        
      end
      
    end
    
    # JI "major" scale (?)... very sweet + endearing
    PITCH_RATIOS = [1.0, 9/8.0, 5/4.0, 4/3.0, 3/2.0, 5/3.0, 7/4.0]
        
    # JI octotonic... a bit square with those high prime numerators
    # PITCH_RATIOS = [1.0, 9/8.0, 5/4.0, 11/8.0, 3/2.0, 13/8.0, 7/4.0, 15/8.0]
    
    # JI "pentatonic" scale... off-kilter quality
    # PITCH_RATIOS = [5/5.0, 6/5.0, 7/5.0, 8/5.0, 9/5.0]
    
    # m3?
    # PITCH_RATIOS = [1.0, 13/11.0]
    
    # JI "mixto"
    # PITCH_RATIOS = [1.0, 6/5.0, 5/4.0, 3/2.0, 8/5.0, 7/4.0, 9/5.0]
    
  end
end