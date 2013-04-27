# 
# start.coffee: Start playing when transport starts.
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Start extends Module
  
  # Play on start.
  # 
  transportStart: (time) ->
    Loom::play(time)
    return time
