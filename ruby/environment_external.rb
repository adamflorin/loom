# 
#  environment_external.rb: Max object for "environment" object
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 


require "tools/monkeypatch"
require "music_loom/music_loom"


# INIT
# 
# build environment
$environment = MusicLoom::Environment.new(:phrygian_ish)

# set_global so that other JRuby for Max instances can get it
set_global(:environment, $environment)


# Ready. Log & notify.
#
puts "Loaded MusicLoom::Environment."
outlet 0, "ready"
