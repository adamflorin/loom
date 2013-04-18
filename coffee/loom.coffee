# 
# loom.coffee: Bootstrap when all other dependencies are loaded
# 
# Copyright 2013 Adam Florin
# 

# init system
# 
logger = new Logger
logger.debug "Initialized logger."

# Called when device is loaded (bang from [live.thisdevice])
# 
init = ->
  logger.debug "Device loaded. Initializing player..."

  try

    # create player if not present
    # 
    # TODO: store in global
    # 
    player = new Player unless player?

    # get module name from args
    # 
    moduleName = jsarguments[1]
    player.loadModule moduleName

    # try it out
    # 
    gesture = player.generateGesture()
    logger.info "Generated!", gesture

  catch e
    logger.error e

# 
# 
logger.info("Loaded Loom")
