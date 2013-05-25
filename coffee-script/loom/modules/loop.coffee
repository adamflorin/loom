# 
# loop.coffee: Pull gesture from history instead of generating new one.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Modules.Loop extends Module

  # Register UI inputs
  # 
  accepts:
    loopLength: "Numeric"
    loopOn: "Numeric"

  # Look for gesture in history. If
  #
  processGesture: (gesture) ->
    if @parameters.loopOn.value == 1
      loopGesture = @player.pastGestures[-@parameters.loopLength.value..][0]
      if loopGesture?
        gesture = loopGesture.cloneAfterTime(gesture.afterTime, @)
    return gesture
