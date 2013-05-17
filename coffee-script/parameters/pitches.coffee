# 
# pitch.coffee: Get pitch set from Max's [kslider].
# 
# Copyright 2013 Adam Florin
# 

class Loom::parameters.Pitches extends Parameter
  mixin @, Serializable
  @::serialized "pitches"

  # 
  # 
  constructor: (@name, parameterData) ->
    @deserialize parameterData
    parameterData
    @pitches ?= -1

  # Given a normal pitch (0-11), provide the nearest pitch in the user-selected
  # pitches array.
  # 
  # Note that, because there's no clean way to transmit an empty set in Max,
  # the first value of @pitches is always -1 and if no pitches are selected it
  # may just be the number -1, not an array.
  # 
  nearestScalePitch: (normalPitch) ->
    if @pitches? and @pitches isnt -1
      pitches = @pitches[1..]
      pitchesByDistance = pitches.sort((x, y) ->
        Math.abs(x - normalPitch) - Math.abs(y - normalPitch))
      pitchesByDistance[0]
    else
      normalPitch
