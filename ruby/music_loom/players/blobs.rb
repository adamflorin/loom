# 
#  blobs.rb
#  from blob-tracking
#  
#  Created by Jasper Speicher on 2011-03-29.
#  Copyright 2011 JJS. All rights reserved.
# 
module MusicLoom
  class Blobs < Player
    
    # you can specify integer :weight
    # OR bind it to a param using :weight param (will auto generate weights btw 0-100)
    # 
    # the weight generated from :weight_param will takes precedence over
    # the :weight if there is one.
    # 
    def initialize
      @motifs = [
        {:class => UmmYeahSure, :weight => 1.0}]
        #{:class => WarmVibe, :weight_param => {:temperature => 1.0}},
        #{:class => CoolVibe, :weight_param => {:temperature => 0.0}}]
      super
    end
    
  end
end
