# 
# meter.coffee: set player's meter
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Meter extends Module

  # Number of meter options.
  # 
  NUM_METERS: 6
  NUM_SUBDIVIDING_METERS: 2

  # Register UI inputs
  # 
  accepts: meter: ["Gaussian", bands: @::NUM_METERS]

  # Shift meter.
  # 
  # Constrain meter to powers of two for now
  # 
  gestureData: (gestureData) ->
    meterIndex = Math.floor(@parameters.meter.generateValue() * @NUM_METERS)
    gestureData.meter = Math.pow(2, @NUM_SUBDIVIDING_METERS - meterIndex)
    return gestureData
