# 
# meter.coffee: set player's meter
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Meter extends Module

  # Register UI inputs
  # 
  accepts: meter: "Gaussian"

  # Shift meter.
  # 
  # Constrain meter to powers of two for now
  # 
  gestureData: (gestureData) ->
    gestureData.meter =
      Math.pow(2, 2 - Math.round(@parameters.meter.generateValue() * 5))
    return gestureData
