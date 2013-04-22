# 
# loom.coffee: Bootstrap Loom framework.
# 
# Copyright 2013 Adam Florin
# 

# init system
# 
logger = new Logger
player = null
Max::initTooltips()


# Called when device is loaded (bang from [live.thisdevice])
# 
init = ->
  try
    logger.debug "Device loaded. Initializing player..."

    # create player if not present
    # 
    player = new Player unless player?

    # get module name from args
    # 
    moduleName = jsarguments[1]
    player.loadModule moduleName

    # clear all gestures when transport stops
    # 
    Live::onStartStop (transportState) ->
      try
        if transportState == 1
          now = Live::now()

          # Live bizarrely sends 2x transport start events:
          # one _before_ the playhead has been reset to zero,
          # and one just after.
          # 
          # Anticipate this and consider that first "start" event
          # to be zero here.
          # 
          now = 0 if now > 0.1

          player.generateGesture(now)
          nextEvent()
        else
          player.clearGestures()
      catch e
        logger.error e

  catch e
    logger.error e

# Output next event
# 
nextEvent = ->
  try
    now = Live::now()
    event = player.nextEvent(now)
    logger.debug "Outputting event", event
    outlet 0, event
  catch e
    logger.error e

# 
# 
logger.info("Loaded Loom")
