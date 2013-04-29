# 
# loom.coffee: Bootstrap Loom framework.
# 
# Divided into three "mixins": Devices, Observers, Messages.
# 
# Copyright 2013 Adam Florin
# 

class Loom

  # Devices
  # 
  # Manage Devices and their respective Players and Modules.
  # 
  @mixin Devices:

    # Modules register themselves here so they can be looked up by name.
    # 
    modules: {}

    # 
    # 
    players: ->
      loom.players ?= []

    # Get player from ID
    # 
    player: (playerId) ->
      do => return player for player in @players() when player.id is playerId

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

    # Create player if it doesn't already exist, and load this module either way.
    # 
    createThisPlayer: () ->
      @players().push new Player Live::playerId()

    # 
    # 
    loadThisPlayerModule: () ->
      @thisPlayer().loadModule(jsarguments[1], Live::deviceId())

    # Is device enabled or "muted"?
    # 
    # This fires before 'initDevice', so make sure module is loaded.
    # 
    enabled: (isEnabled) ->
      @thisPlayer()?.muteModule(Live::deviceId(), !isEnabled)

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
      player = @player(playerId)
      if player
        player.unloadModule Live::deviceId()
        @destroyPlayer(playerId) if player.modules.length is 0

    # Rebuild players array, without specified player.
    # 
    destroyPlayer: (playerId) ->
      fewerPlayers = (player for player in @players() when player.id isnt playerId)
      loom.players = fewerPlayers
      logger.info "Player #{playerId}: Destroyed"

  # Observers
  # 
  # Receive events from Live and call into Player as necessary.
  # 
  # Note that some initial events arrive before player has been initialized.
  # 
  @mixin Observers:

    # Live "transport start" event fires an indeterminte duration of time
    # after transport has actually started. (See followTransport() below.)
    # 
    # This value appears to typically be within 60ms.
    # 
    # This "allowable delay" is in beats, and assumes 120bpm (for now).
    # 
    TIME_DELAY_THRESHOLD: 0.12

    # Listen for transport start/stop
    # 
    # Note that if the transport is at a time other than zero when it starts,
    # Live will send 2x transport start events--one before the transport starts
    # (when the current song time is whatever it was the last time the
    # transport stopped) and another after the transport has started. But if
    # the transport was already at zero, it'll only fire one.
    # 
    # To determine whether we're receiving the "true" transport start,
    # check the time and compare it to the threshold above.
    # 
    observeTransport: (playing) ->
      if playing is 1
        loom.overrideNow = if Live::now() > @TIME_DELAY_THRESHOLD then 0 else null
        unless loom.transportPlaying
          loom.transportPlaying = yes
          @thisPlayer().transportStart()
      else
        loom.transportPlaying = no
        @thisPlayer().clearGestures()

    # Observe when module is added, removed or moved in the chain.
    # Normally, just re-sequence the modules within a given player.
    # 
    # If device has changed players, may have to create or destroy
    # new or old players, respectively, and re-init.
    # 
    observeDevices: (deviceIds...) ->
      if oldPlayerId = Live::detectPlayerChange()
        logger.info "Device #{Live::deviceId()} moved from player #{oldPlayerId} to #{Live::playerId()}"
        @initDevice()
        @destroyDevice(oldPlayerId)
      else
        @thisPlayer()?.sortModules(deviceIds)

    # Receive coarse time updates just to make sure we haven't slipped behind.
    # 
    observeTime: (time) ->
      @thisPlayer().clearOverdueEvents(time)

  # Messages
  # 
  # Receive and send Max messages, from and to self or other devices.
  # 
  @mixin Messages:

    # "Play" means: generate a gesture and start outputting.
    # 
    # But don't play if transport is stopped, or there will be dangling events.
    # 
    play: (time) ->
      @thisPlayer().play(time) if loom.transportPlaying

    # Get next event off the queue. Re-route in case output module was
    # moved while an event was out for dispatch.
    # 
    eventTriggered: ->
      @thisPlayer().eventComplete()

    # Send event to Max to be scheduled.
    # 
    # Note: It is indeterminate which device in a player's rack will output
    # events, depending on which device received the initial "play" message.
    # As long as no two devices ever have events "out" in Max at the same time
    # (a scenario Player should never allow), this indeterminacy is not a
    # problem.
    # 
    outputEvent: (event) ->
      outlet 0, event.serialize()

    # Dispatch message to a player's "output" module. Default to this player.
    # 
    messagePlayerOutputDevice: (message, playerId) ->
      player = @player(playerId || Live::playerId())
      if player
        deviceId = player.outputModuleId()
        @messageDevice message, deviceId

    # Dispatch message to specified device, or self by default.
    # 
    messageDevice: (message, deviceId) ->
      deviceId ?= Live::deviceId()
      @messageAll ["forDevice", deviceId].concat(message)

    # Output to a [send] which goes to all Loom devices.
    # 
    messageAll: (message) ->
      outlet 1, message
