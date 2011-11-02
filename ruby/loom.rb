# 
#  loom.rb: Ruby generative music tools for MaxForLive
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

require "loom/core_ext"
require "loom/tools/randomness"
require "loom/tools/timing"
require "loom/tools/tonality"
require "loom/environment"
require "loom/event"
require "loom/generator"
require "loom/gesture"
require "loom/player"
Dir.glob(File.dirname(__FILE__) + '/loom/event/*', &method(:require))
Dir.glob(File.dirname(__FILE__) + '/loom/player/*', &method(:require))

# 
# 
module Loom
  # extend Tools
end
