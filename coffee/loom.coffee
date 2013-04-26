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
    @messageResetObservers ["transport", "modules"]

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
  # By the time this is called, module may already have been removed
  # from player. So just destroy player if no modules remain.
  # Then tell all devices in this player to refresh themselves.
  # 
  # Note that if this is being called from [freebang], LiveAPI is no longer
  # avalable.
  # 
  destroyDevice: (playerId) ->
    playerId ?= Live::playerId()
    @player(playerId).unloadModule Live::deviceId()
    @destroyPlayer(playerId) if @player(playerId).modules.length is 0
    @messageResetObservers ["transport", "modules"]

  # Rebuild players array, without specified player.
  # 
  destroyPlayer: (playerId) ->
    fewerPlayers = (player for player in @players() when player.id isnt playerId)
    (new Global("loom")).players = fewerPlayers
    logger.info "Destroyed player ID #{playerId}"

  # Is deviced enabled or "muted"?
  # 
  # This fires before 'initDevice', so make sure module is loaded.
  # 
  enabled: (isEnabled) ->
    @thisPlayer()?.muteModule(Live::deviceId(), !isEnabled)

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

  # "Play" means: generate a gesture and start outputting.
  # 
  play: ->
    unless @routeInputMessage("play")
      @thisPlayer().generateGesture()
      @thisPlayer().nextEvent()

  # Get next event off the queue. Re-route in case output module was
  # moved while an event was out for dispatch.
  # 
  nextEvent: ->
    unless @routeInputMessage("nextEvent")
      @thisPlayer().nextEvent()

  # Send event to Max to be scheduled.
  # 
  outputEvent: (event) ->
    logger.debug "Outputting event", event
    outlet 0, event

  # Input messages may only go to the designated "output" device.
  # If this isn't it, pass the message along to it, and return true.
  # 
  # Because each module has the capacity to output MIDI events, we must
  # assign output responsibility to just one of them, so that events are
  # not output redundantly.
  # 
  routeInputMessage: (message) ->
    unless Live::deviceId() is @thisPlayer().outputModuleId()
      @messagePlayerOutputDevice message
      return true

  # Reset observers as requested by Loom::messageResetObservers()
  # 
  resetObservers: (observers) ->
    logger.debug "observers", observers
    if observers.indexOf("modules") >= 0
      Loom::followModuleChange()
    if observers.indexOf("transport") >= 0
      Loom::followTransport()

  # Notify all Loom devices that they should re-register their observers.
  # (Or just one device if deviceId is specified.)
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
  messageResetObservers: (observers, deviceId) ->
    message = ["resetObservers"].concat(observers)
    if deviceId
      @messageDevice message, deviceId
    else
      @messageAll message

  # Dispatch a message to a player's "output" module. Default to this player.
  # 
  messagePlayerOutputDevice: (message, playerId) ->
    player = @player(playerId || Live::playerId())
    if player
      deviceId = player.outputModuleId()
      @messageDevice message, deviceId

  messageDevice: (message, deviceId) ->
    @messageAll ["forDevice", deviceId].concat(message)

  # Output to a [send] which goes to all Loom devices.
  # 
  messageAll: (message) ->
    outlet 1, message
