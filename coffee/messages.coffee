# 
# messages.coffee: Max messages accepted by [js] object's left inlet.
# 
# Copyright 2013 Adam Florin
# 

# Called when device is loaded and LiveAPI is available
# (bang from [live.thisdevice])
# 
init = ->
  try
    # Create player if not present
    # 
    if Live::numSiblingDevices() is 1
      Loom::players().push new Player(Live::playerId())

    # Load player module
    # 
    Loom::thisPlayer().loadModule jsarguments[1], Live::deviceId()

    # Get updates on player module list, in case we've been moved.
    # 
    Live::onPlayerUpdate Loom::updatePlayer

    # Callback on transport start/stop
    # 
    Live::onStartStop (playing) ->
      try
        if playing
          now = Live::now()

          # Live bizarrely sends 2x transport start events:
          # one _before_ the playhead has been reset to zero,
          # and one just after.
          # 
          # Anticipate this and consider that first "start" event
          # to be zero here.
          # 
          now = 0 if now > 0.1

          Loom::thisPlayer().generateGesture(now)
          nextEvent()
        else
          Loom::thisPlayer().clearGestures()
      catch e
        logger.error e

  catch e
    logger.error e

# Output next event
# 
nextEvent = ->
  try
    now = Live::now()
    event = Loom::thisPlayer().nextEvent(now)
    logger.debug "Outputting event", event
    outlet 0, event
  catch e
    logger.error e

# Called from [freebang]
# 
# Remove module from player. If it's the last module, destroy player.
# 
# NOTE that LiveAPI is no longer available at this point.
# 
destroy = ->
  try
    if Loom::thisPlayer().modules.length == 1
      Loom::destroyPlayer Live::playerId()
    else
      Loom::thisPlayer().unloadModule Live::deviceId()
  catch e
    logger.error e
