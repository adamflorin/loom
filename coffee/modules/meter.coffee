# 
# meter.coffee: set player's meter
# 
# Copyright 2013 Adam Florin
# 

class Loom::modules.Meter extends Module

  # Shift meter.
  # 
  # Constrain meter to powers of two for now
  # 
  gestureData: (gestureData) ->
    gestureData.meter =
      Math.pow(2, 2 - Math.round(@generateValue("meter") * 5))
    return gestureData
