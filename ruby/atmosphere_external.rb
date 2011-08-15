# 
#  atmosphere_external.rb: Max object for "atmosphere" object
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 


require "tools/monkeypatch"
require "music_loom/music_loom"


# INIT
# 
# build atmosphere
$atmosphere = MusicLoom::Atmosphere.new(:phrygian_ish)

# set_global so that other JRuby for Max instances can get it
set_global(:atmosphere, $atmosphere)


# Ready. Log & notify.
#
puts "Loaded MusicLoom::Atmosphere."
outlet 0, "ready"
