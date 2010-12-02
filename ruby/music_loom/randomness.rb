# 
#  randomness.rb: number generation!
#  
#  Copyright December 2010, Adam Florin. All rights reserved.
# 
module MusicLoom
  module Randomness
    module ClassMethods
      
      # From: http://matt.blogs.it/entries/00002641.html
      # Author: Matt Mower
      # 
      def box_mueller( mean = 0.0, stddev = 1.0 )
        x1 = 0.0, x2 = 0.0, w = 0.0

        until w > 0.0 && w < 1.0
          x1 = 2.0 * rand - 1.0
          x2 = 2.0 * rand - 1.0
          w = ( x1 * x2 ) + ( x2 * x2 )
        end

        w = Math.sqrt( -2.0 * Math.log( w ) / w )
        r = x1 * w

        mean + r * stddev
      end
      
      alias_method :gaussian_rand, :box_mueller
      
    end
    
    def self.included(receiver)
      receiver.extend ClassMethods
    end
    
  end
end
