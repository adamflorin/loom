# 
# loop.coffee: Pull gesture from history instead of generating new one.
# 
# Copyright 2013 Adam Florin
# 

class Loom::Modules.Loop extends Module
  mixin @, Serializable
  @::serialized "loopGestures", "loopGesturesIndex"

  # Register UI inputs
  # 
  accepts:
    loopLength: "Numeric"
    loopOn: "Numeric"

  # Persist a copy of Player's gesture when loop is switched on.
  # 
  onParameterValue:
    loopOn:
      value: (value) ->
        value = value == 1
        @loopGestures = if value
          (gesture.serialize() for gesture in @loadPlayer().pastGestures)
        else
          []
        @loopGesturesIndex = 0
        return value
    loopLength:
      value: (value) ->
        @loopGesturesIndex = constrain @loopGesturesIndex || 0, value
        return value

  # Clear on stop.
  # 
  transportStop: ->
    @loopGestures = []
    @loopGesturesIndex = 0

  # Look up gesture in history.
  #
  processGesture: (gesture) ->
    if @parameters.loopOn.value
      @fillLoopGestures()
      if @loopGestures.length >= @parameters.loopLength.value
        ng = @nextGestureIndex()
        gestureData = @loopGestures[-ng..][0]
        loopGesture = new Gesture gestureData
        gesture = loopGesture.cloneAfterTime(gesture.afterTime, @)
    return gesture

  # If loop gestures is not as long as loop length would like, the player has
  # been generating new gestures, not looping old ones. Grab those fresh
  # generated gestures and archive them here for later looping.
  # 
  fillLoopGestures: ->
    numNeededGestures = @parameters.loopLength.value - @loopGestures.length
    if numNeededGestures > 0
      if @player.pastGestures.length >= @parameters.loopLength.value
        @loopGestures = @loopGestures.concat(
          for gesture in @player.pastGestures[-numNeededGestures..]
            gesture.serialize())

  # Return next index to use in loopGestures array, and increment/wrap.
  # 
  nextGestureIndex: ->
    index = @parameters.loopLength.value - @loopGesturesIndex
    @loopGesturesIndex += 1
    @loopGesturesIndex = 0 if @loopGesturesIndex >= @parameters.loopLength.value
    return index
