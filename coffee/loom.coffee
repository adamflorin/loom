# 
# loom.coffee: Bootstrap Loom framework. Manage player (re-)initialization,
# hook into Live and Max APIs, output messages.
# 
# Copyright 2013 Adam Florin
# 

class Loom
  # 
  # 
  players: ->
    (new Global("loom")).players ?= []

  # Get this player.
  # 
  thisPlayer: ->
    (player for player in @players() when player.id is Live::playerId())[0]
  
  # Create player if it doesn't already exist, and load this module either way.
  # 
  createThisPlayer: () ->
    @players().push new Player Live::playerId()

  # 
  # 
  loadThisPlayerModule: () ->
    @thisPlayer().loadModule(jsarguments[1], Live::deviceId())

  # Destroy and re-init this player, preserving all modules as they are,
  # except this one, which we also re-init.
  # 
  # This is invoked on a script reload, which is why each device is responsible
  # for reloading its own module. All devices redundantly reload player, as
  # that's simpler and probably safer than maintaining some register of which
  # devices have reloaded, in which order, etc.
  # 
  reloadThisPlayerModule: -> 
    playerModules = @thisPlayer().modules
    @destroyPlayer Live::playerId()
    @createThisPlayer()
    @thisPlayer().modules = playerModules
    @thisPlayer().unloadModule Live::deviceId()
    @loadThisPlayerModule()

  # Rebuild players array, without specified player.
  # 
  destroyPlayer: (playerId) ->
    fewerPlayers = (player for player in @players() when player.id isnt playerId)
    (new Global("loom")).players = fewerPlayers
    logger.info "Destroyed player ID #{playerId}"

  # Listen for transport start/stop
  # 
  # Live bizarrely sends 2x transport start events:
  # one _before_ the playhead has been reset to zero,
  # and one just after.
  # 
  # Anticipate this and consider that first "start" event
  # to be zero here.
  # 
  followTransport: ->
    Live::onStartStop (playing) =>
      try
        if playing
          now = Live::now()
          now = 0 if now > 0.1

          @thisPlayer().generateGesture(now)

          @nextEvent()
        else
          @thisPlayer().clearGestures()
      catch e
        logger.error e

  # Observe when module is added, removed or moved in the chain.
  # 
  followModuleChange: ->
    Live::onPlayerUpdate (deviceIds) =>
      try
        @thisPlayer().sortModules(deviceIds)
      catch e
        logger.error e

  # 
  # 
  nextEvent: ->
    event = [0, "note", 60, 100, 777] #@thisPlayer().nextEvent()
    logger.debug "Outputting event", event
    outlet 0, event

  # Send message to this player's devices. Max will make sure it doesn't
  # feed back into this device (whic is being destroyed).
  # 
  # Must use [send] in this case as LiveAPI is no longer available
  # (which we could use to send to each device individually here).
  # 
  resetPlayerObservers: ->
    outlet 1, ["resetPlayerObservers", Live::playerId()]
