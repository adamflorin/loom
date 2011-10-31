# 
#  music_loom.rb: Ruby generative music tools for MaxForLive
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

require "music_loom/event"
require "music_loom/gesture"
require "music_loom/motif"
require "music_loom/generator"
require "music_loom/player"
require "music_loom/space"
require "music_loom/randomness"
require "music_loom/tonality"
require "music_loom/environment"

Dir.glob(File.dirname(__FILE__) + '/event/*', &method(:require))
Dir.glob(File.dirname(__FILE__) + '/behaviors/*', &method(:require))
Dir.glob(File.dirname(__FILE__) + '/players/*', &method(:require))

# 
# 
module MusicLoom
  extend Randomness
  extend Space
end
