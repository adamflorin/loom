# 
#  Rakefile: tools for Music Loom
#  
#  Copyright October 2010, Adam Florin. All rights reserved.
# 

task :default => [:load]

desc "Just require the music_loom source to check for compile errors"
task :load do
  $LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + "/ruby"
  require "music_loom/music_loom"
  puts "Loaded music_loom OK."
end
