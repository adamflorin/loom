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

    # Module (sub)class name is passed in as an argument to the [js] box.
    # Look up the proper class by name in our modules array.
    # 
    moduleClass: (name) => @::modules[name || jsarguments[1]]

    # Create player if necessary and own module, then reset observers for all
    # modules of this player. (Adding a device to a chain can knock out the other
    # devices' observers).
    # 
    initDevice: ->
      Live::resetCache()
      @liveReady = yes
      logger.warn "Module created outside of rack" unless Live::deviceInRack()

      module = @moduleClass()::load Live::deviceId()
      module.save()

      player = Player::load Live::playerId()
      player.save()

    # Set module parameter. If Live isn't ready yet (haven't received initDevice)
    # then do nothing.
    # 
    moduleMessage: (name, value) ->
      if @liveReady
        module = @moduleClass()::load Live::deviceId()
        module[name] = value
        module.save()

    # Destroy device.
    # 
    # Note that if this is being called from [freebang], LiveAPI is no longer
    # avalable.
    # 
    destroyDevice: (playerId) ->
      module = @moduleClass()::load Live::deviceId()
      module.destroy()
      @destroyPlayerIfEmpty(playerId)

    # If player has no more modules, destroy it.
    # 
    # Optional playerId arg defaults to current player.
    # 
    destroyPlayerIfEmpty: (playerId) ->
      playerId ?= Live::playerId()
      player = (Player::load playerId)
      player.destroy() if player.moduleIds.length is 0

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
        Persistence::connection.overrideNow =
          if Live::now() > @TIME_DELAY_THRESHOLD then 0 else null
        unless Persistence::connection.transportPlaying
          Persistence::connection.transportPlaying = yes
          player = Player::load Live::playerId()
          player.transportStart()
          player.save()
      else
        Persistence::connection.transportPlaying = no
        player = Player::load Live::playerId()
        player.clearGestures()
        player.save()

    # Observe when module is added, removed or moved in the chain.
    # Normally, just re-sequence the modules within a given player.
    # 
    # If device has changed players, may have to create or destroy
    # new or old players, respectively, and re-init.
    # 
    observeDevices: (deviceIds...) ->
      if oldPlayerId = Live::detectPlayerChange()
        @initDevice()
        @destroyPlayerIfEmpty()
      else
        player = Player::load Live::playerId()
        player.moduleIds = deviceIds
        player.save()
    
  # Messages
  # 
  # Receive and send Max messages, from and to self or other devices.
  # 
  @mixin Messages:

    # Player entrypoint.
    # 
    # "Play" means: generate a gesture and start outputting.
    # 
    # But don't play if transport is stopped, or there will be dangling events.
    # 
    # Save player state when finished.
    # 
    play: (time) ->
      if Persistence::connection.transportPlaying
        player = Player::load Live::playerId()
        player.play(time)
        player.save()

    # Player entrypoint.
    # 
    # Notification from patcher that all events have been dispatched.
    # 
    eventQueueEmpty: ->
      player = Player::load Live::playerId()
      player.eventQueueEmpty()
      player.save()

    # Invoked by player.
    # 
    # Output array of events to [event-queue] and schedule next event.
    # 
    # Note: It is indeterminate which device in a player's rack will output
    # events, depending on which device received the initial "play" message.
    # As long as no two devices ever have timed events "out" in Max at the
    # same time (a scenario Player should never allow), this indeterminacy
    # is not a problem.
    # 
    scheduleEvents: (events) ->
      outlet 1, event.serialize() for event in events
      outlet 0, "schedule"

    # Invoked by player.
    # 
    # Clear patcher event queue.
    # 
    clearEventQueue: ->
      outlet 0, "clear"
