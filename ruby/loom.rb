# 
#  loom.rb: Ruby generative music tools for MaxForLive
#  
#  Copyright 2010-2013, Adam Florin. All rights reserved.
# 

LOOM_ROOT = File.dirname(__FILE__)

# require core
# 
[ "loom/core_ext",
  "loom/tools/randomness",
  "loom/tools/timing",
  "loom/tools/tonality",
  "loom/logger",
  "loom/max",
  "loom/environment",
  "loom/event",
  "loom/generator",
  "loom/gesture",
  "loom/player"].each do |file|
    require File.join(LOOM_ROOT, file)
  end

# require events + players
# 
Dir.glob(File.join(LOOM_ROOT, "/loom/event/*"), &method(:require))
Dir.glob(File.join(LOOM_ROOT, "/loom/player/*"), &method(:require))
