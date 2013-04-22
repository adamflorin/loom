# 
# max.coffee: integration with Max
# 
# Copyright 2013 Adam Florin
# 

class Max
  # 
  # 
  initTooltips: ->
    setinletassist(0, "Loom message input")
    setoutletassist(0, "Timed event output")
  
  # 
  # 
  patcherDirPath: ->
    patcher.filepath.match(/^(.+\/)([^/]+)$/)[1]

  # wrapper
  # 
  time: () -> max.time

  # Math utility
  # 
  beatsToTicks: (beats) ->
    beats * 480
