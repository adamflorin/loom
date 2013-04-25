# 
# loom.coffee: Bootstrap Loom framework. Manage player (re-)initialization,
# hook into Live and Max APIs, output messages.
# 
# Copyright 2013 Adam Florin
# 

class Loom

  # Modules define themselves here so they can be looked up by name.
  # 
  @::modules = {}

  # Live "transport start" event fires an indeterminte duration of time
  # after transport has actually started. (See followTransport() below.)
  # 
  # This value appears to typically be within 60ms.
  # 
  # This "allowable delay" is in beats, and assumes 120bpm (for now).
  # 
  @::ALLOWABLE_TRANSPORT_START_DELAY = 0.12

  # 
  # 
  players: ->
    (new Global("loom")).players ?= []

  # Get player from ID
  # 
  player: (playerId) ->
    (player for player in @players() when player.id is playerId)[0]

  # Get this player.
  # 
  thisPlayer: ->
    @player(Live::playerId())
  
  # Create player if necessary and own module, then reset observers for all
  # modules of this player. (Adding a device to a chain can knock out the other
  # devices' observers).
  # 
  initDevice: ->
    logger.warn "Module created outside of rack" unless Live::deviceInRack()
    @createThisPlayer() unless @thisPlayer()?
    @loadThisPlayerModule()
    @resetObservers ["transport", "modules"]

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

  # Destroy device. Optional playerId arg defaults to current player.
  # 
  # If player has no more modules, destroy it, too.
  # 
  destroyDevice: (playerId) ->
    playerId ?= Live::playerId()
    @player(playerId).unloadModule Live::deviceId()
    @destroyPlayer(playerId) if @player(playerId).modules.length is 0
    @resetObservers ["transport", "modules"]

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
          now = 0 if now > @ALLOWABLE_TRANSPORT_START_DELAY
          @thisPlayer().transportStart(now)
        else
          @thisPlayer().clearGestures()
      catch e
        logger.error e

  # Observe when module is added, removed or moved in the chain.
  # Normally, just re-sequence the modules within a given player.
  # 
  # If device has changed players, may have to create or destroy
  # new or old players, respectively, and re-init.
  # 
  followModuleChange: ->
    Live::onPlayerUpdate (deviceIds) =>
      try
        if oldPlayerId = Live::detectPlayerChange()
          logger.info "Device #{Live::deviceId()} moved from player #{oldPlayerId} to #{Live::playerId()}"
          @initDevice()
          @destroyDevice(oldPlayerId)
        else
          @thisPlayer().sortModules(deviceIds)
      catch e
        logger.error e

  # Send event to Max to be scheduled.
  # 
  outputEvent: (event) ->
    logger.debug "Outputting event", event
    outlet 0, event

  # Notify *all* Loom devices that they should re-register their observers.
  # 
  # Do this liberally, because observers have a tendency to go dark after
  # any environmental change (device added/moved/removed, script reloaded),
  # and we can't risk losing touch with a critical observer.
  # 
  # This means we frequently redundantly re-register observers
  # multiple times for a given device, because there's no way to test whether
  # an observer has gone dark or not.
  # 
  # This also means that we might get tied up for 100s of milliseconds just
  # re-registering handlers, but at least the CPU cost is minimal in the
  # low-priority thread.
  # 
  # Use Max [send] rather than LiveAPI to access sibling patchers as LiveAPI
  # is no longer available in one of our basic use cases: freeing patcher.
  # 
  # Note that in that [freebang] scenario as well, the patcher ensures that
  # this devices does not receive this message unnecessarily.
  # 
  resetObservers: (observers) ->
    outlet 1, ["resetObservers"].concat(observers)
