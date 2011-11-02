# 
#  loom.rb: Ruby generative music tools for MaxForLive
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

require "loom/event"
require "loom/gesture"
require "loom/motif"
require "loom/generator"
require "loom/player"
require "loom/space"
require "loom/randomness"
require "loom/tonality"
require "loom/environment"

Dir.glob(File.dirname(__FILE__) + '/event/*', &method(:require))
Dir.glob(File.dirname(__FILE__) + '/behaviors/*', &method(:require))
Dir.glob(File.dirname(__FILE__) + '/players/*', &method(:require))

# 
# 
module Loom
  extend Randomness
  extend Space
end
