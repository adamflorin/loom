# 
# 
# 
# Copyright 2013 Adam Florin
# 

class Probability
  
  # Return true if heads, given chance as a fraction of 1.0.
  # 
  flip: (chance) ->
    parseInt(Math.random() * (1/chance)) == 0

  # Box Mueller algorithm for Gaussian or normal distribution.
  # 
  gaussian: (mean, deviation) ->
    x1 = 0.0
    x2 = 0.0
    w = 0.0

    until w > 0.0 and w < 1.0
      x1 = 2.0 * Math.random() - 1.0
      x2 = 2.0 * Math.random() - 1.0
      w = ( x1 * x2 ) + ( x2 * x2 )

    w = Math.sqrt( -2.0 * Math.log( w ) / w )
    r = x1 * w

    mean + r * deviation

  # Constrain value between 0.0-1.0.
  # 
  constrain: (number) ->
    Math.max(0.0, Math.min(1.0, number))

  # Given "start" and "end" values, move toward "end" value in proportion to
  # given "inertia" (0.0-1.0).
  # 
  applyInertia: (start, end, inertia) ->
    start + (end - start) * (1.0 - inertia)
