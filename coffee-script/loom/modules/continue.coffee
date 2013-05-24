# 
# continue.coffee: When there are no more events in the future, generate another.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Modules.Continue extends Module
  
  # When there are no more events in the future, generate another.
  # 
  gestureOutputComplete: -> @player.play()
