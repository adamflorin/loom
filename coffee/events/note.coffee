# 
# 
# 
# 
# 

class Note extends Event
  
  DEFAULT_PITCH = 60
  DEFAULT_VELOCITY = 100

  # 
  # 
  constructor: (at, meter) ->
    @pitch = DEFAULT_PITCH
    @velocity = DEFAULT_VELOCITY
    @duration = meter
    super at

  # 
  # 
  serialize: ->
    super [@pitch, @velocity, @duration]
