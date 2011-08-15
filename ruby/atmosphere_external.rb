# 
#  atmosphere_external.rb: Max object for "atmosphere" object
#  
#  Copyright November 2010, Adam Florin. All rights reserved.
# 

# relative to ruby.loadpaths in ajm.ruby.properties.
# For some reason, Ruby doesn't know the path of this external file.
# 
require "tools/monkeypatch"
require "music_loom/music_loom"


# INIT
# 
# build atmosphere
$atmosphere = MusicLoom::Atmosphere.new(:phrygian_ish)

# set_global so that other ajm.ruby instances can get it
set_global(:atmosphere, $atmosphere)


# Ready. Log & notify.
#
puts "Loaded MusicLoom::Atmosphere."
outlet 0, "ready"
