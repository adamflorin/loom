# 
#  music_loom.rb: Ruby generative music tools for MaxForLive
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 


require "music_loom/gesture"
require "music_loom/repertoire"


APP_ROOT = File.expand_path(File.dirname(__FILE__)) + "/"

# require all individual gestures & repertoires
["gestures", "repertoires"].each do |dir|
  dir_path = "#{APP_ROOT}#{dir}"
  
  if File.directory? dir_path
    Dir.entries(dir_path).reject{|fn| fn =~ /^\./}.each do |filename|
      require "#{dir_path}/#{filename}"
    end
  end
end


# 
# 
module MusicLoom
  
end
