# 
# pitch.coffee: Set MIDI pitch
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Pitch extends Module

  # Hard code for now
  # 
  @::OCTAVE_RANGE = 3
  @::LOWEST_PITCH = 36

  # Generate a any MIDI number as a pitch, then conform it to user-specified
  # pitches and apply it to gesture events.
  # 
  processGesture: (gesture) ->
    pitch = Math.round(@generateValue("pitch") * (@OCTAVE_RANGE * 12)) + @LOWEST_PITCH
    adjustedPitch = @nearestScalePitch(pitch % 12) + @cBelow(pitch)
    note.pitch = adjustedPitch for note in gesture.events when note.constructor.name is "Note"
    return gesture

  # Given a normal pitch (0-11), provide the nearest pitch in the user-selected
  # pitches array.
  # 
  nearestScalePitch: (normalPitch) ->
    pitches = @parameters.pitches?.pitches
    if pitches? isnt -1
      pitches = pitches[1..]
      pitchesByDistance = pitches.sort((x, y) ->
        Math.abs(x - normalPitch) - Math.abs(y - normalPitch))
      pitchesByDistance[0]
    else
      normalPitch

  # Return pitch of the nearest C below
  # 
  cBelow: (pitch) ->
    Math.floor(pitch/12) * 12
