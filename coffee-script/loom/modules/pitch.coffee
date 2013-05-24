# 
# pitch.coffee: Set MIDI pitch
# 
# Copyright 2013 Adam Florin
# 

class Loom::Modules.Pitch extends Module

  # Register UI inputs
  # 
  accepts:
    pitch: "Gaussian"
    pitches: "Pitches"

  # Hard code for now
  # 
  OCTAVE_RANGE: 3
  LOWEST_PITCH: 36

  # Generate a any MIDI number as a pitch, then conform it to user-specified
  # pitches and apply it to gesture events.
  # 
  processGesture: (gesture) ->
    pitch = @LOWEST_PITCH +
      Math.round(@parameters.pitch.generateValue() * (@OCTAVE_RANGE * 12))
    adjustedPitch = @parameters.pitches.nearestScalePitch(pitch % 12) +
      @cBelow(pitch)
    for note in gesture.events when note.constructor.name is "Note"
      note.pitch = adjustedPitch
    return gesture

  # Return pitch of the nearest C below
  # 
  cBelow: (pitch) ->
    Math.floor(pitch/12) * 12
