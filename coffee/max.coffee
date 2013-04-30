# 
# max.coffee: integration with Max
# 
# Copyright 2013 Adam Florin
# 

# Max `jsthis` properties must be set globally without being declared with `var`.
# 
`autowatch = 1`

# Tooltips
# 
setinletassist(0, "Loom message input")
setoutletassist(0, "Timed event output")

class Max
  # 
  # 
  patcherDirPath: ->
    patcher.filepath.match(/^(.+\/)([^/]+)$/)[1]

  # Math utility
  # 
  beatsToTicks: (beats) ->
    beats * 480
