# 
# max.coffee: integration with Max
# 
# Copyright 2013 Adam Florin
# 

# Max `jsthis` properties must be set globally without being declared with `var`.
# 
`outlets = 2`
`autowatch = 1`

# Tooltips
# 
setinletassist(0, "Loom message input")
setoutletassist(0, "Timed event output")
setoutletassist(1, "Messages for other devices")

class Max
  # 
  # 
  patcherDirPath: ->
    patcher.filepath.match(/^(.+\/)([^/]+)$/)[1]

  # Run message into [js] input via a [deferlow], which can be critical
  # for certain LiveAPI calls to work at all.
  # 
  messageAtLowPriority: (msg) ->
    patcher.getnamed("loom-low-priority").message(msg)

  # Math utility
  # 
  beatsToTicks: (beats) ->
    beats * 480
