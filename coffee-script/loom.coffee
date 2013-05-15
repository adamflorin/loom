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
  mixin @, Devices:

    # Module and event classes register themselves here so they can be looked
    # up by name.
    # 
    modules: {}
    events: {}

    # Look up the proper class by name in our modules or events array.
    # 
    # Module (sub)class name is passed in as an argument to the [js] box.
    # 
    # 
    moduleClass: (name) => @::modules[name]
    eventClass: (name) => @::events[name]

    # Create player if necessary and own module, then reset observers for all
    # modules of this player. (Adding a device to a chain can knock out the other
    # devices' observers).
    # 
    initDevice: ->
      Live::resetCache()
      @liveReady = yes
      Persistence::deviceContext Live::deviceId(), deviceContext

      unless Live::deviceInRack()
        logger.warn "Module created outside of rack"
        Max::displayError "Please place Loom device in a MIDI Effect Rack."
      else
        Max::dismissError()

      moduleClass = @moduleClass jsarguments[1]
      module = moduleClass::load Live::deviceId()
      module.save()

      Player::update Live::playerId(), (player) -> player.refreshModuleIds()

    # Set module parameter. If Live isn't ready yet (haven't received initDevice)
    # then do nothing.
    # 
    moduleMessage: (name, value...) ->
      if @liveReady
        Module::update Live::deviceId(), (module) -> module.set name, value

    # Give modules the chance to update their interfaces after player layout
    # changes.
    # 
    populate: ->
      player.populate?() for player in Player::loadAll()

    # Destroy device.
    # 
    # Note that if this is being called from [freebang], LiveAPI is no longer
    # avalable. However, the basic device/player ID functions should correctly
    # return cached values.
    # 
    destroyDevice: () ->
      deviceId = Live::deviceId()
      Persistence::destroyDeviceContext deviceId
      (Module::load deviceId).destroy()
      @removePlayerModule Live::playerId(), deviceId

    # Remove module from player. If that was the last module, destroy player.
    # Otherwise, save it. It's possible user is moving multiple modules at once
    # and this is not the last call.
    # 
    removePlayerModule: (playerId, deviceId) ->
      player = Player::load playerId
      player.moduleIds = (id for id in player.moduleIds when id isnt deviceId)
      if player.moduleIds.length > 0
        player.save()
      else
        player.destroy()
        @populate()

  # Observers
  # 
  # Receive events from Live and call into Player as necessary.
  # 
  # Note that some initial events arrive before player has been initialized.
  # 
  mixin @, Observers:

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
        Persistence::connection().overrideNow =
          if Live::now(true) > @TIME_DELAY_THRESHOLD then 0 else null
        unless Persistence::connection().transportPlaying
          Persistence::connection().transportPlaying = yes
          Player::update Live::playerId(), (player) -> player.transportStart()
      else
        Persistence::connection().transportPlaying = no
        Player::update Live::playerId(), (player) -> player.clearGestures()

    # Observe when module is added, removed or moved in the chain.
    # Normally, just re-sequence the modules within a given player.
    # 
    # If device has changed players, may have to create or destroy
    # new or old players, respectively, and re-init.
    # 
    # Ignore "bang" argument, and just  get the device IDs from LiveAPI.
    # 
    observeDevices: ->
      if oldPlayerId = Live::detectPlayerChange()
        logger.info "Device #{Live::deviceId()} moved from player #{oldPlayerId} to #{Live::playerId()}"
        @initDevice()
        @removePlayerModule(oldPlayerId, Live::deviceId())
      else
        Player::update Live::playerId(), (player) -> player.refreshModuleIds()
      @populate()
    
  # Messages
  # 
  # Receive and send Max messages, from and to self or other devices.
  # 
  mixin @, Messages:

    # Player entrypoint.
    # 
    # "Play" means: generate a gesture and start outputting.
    # 
    # But don't play if transport is stopped, or there will be dangling events.
    # 
    # Save player state when finished.
    # 
    play: (time) ->
      if Persistence::connection().transportPlaying
        Player::update Live::playerId(), (player) -> player.play(time)

    # Player entrypoint.
    # 
    # Notification from patcher that all events for this device have been
    # dispatched.
    # 
    # 'now' is the current time in beats (float). It comes straight from [when],
    # which is the most reliable way to determine current time. So just set up
    # an override, which will remain in place until the next call to
    # eventQueueEmpty.
    # 
    eventQueueEmpty: (now) ->
      if Persistence::connection().transportPlaying
        Persistence::connection().overrideNow = now
        Player::update Live::playerId(), (player) -> player.eventQueueEmpty()

    # Invoked by player.
    # 
    # Output array of events to [event-queue] and schedule next event.
    # 
    # Check destination device of each event and dispatch to appropriate jsthis.
    # 
    # Note: It is indeterminate which device in a player's rack will output
    # events, depending on which device received the initial "play" message.
    # 
    # If returnDeviceId is specified, notify Max that we expect that device to
    # return here--in the form of an eventQueueEmpty message when events have
    # all been dispatched.
    # 
    scheduleEvents: (events, returnDeviceId) ->
      if returnDeviceId?
        Persistence::deviceContext(returnDeviceId).outlet 0, "return"

      outputDeviceIds = []
      for event in events.sort((x, y) -> x.at - y.at)
        Persistence::deviceContext(event.deviceId).outlet 1, event.output()
        outputDeviceIds.push event.deviceId

      for deviceId in unique(outputDeviceIds)
        Persistence::deviceContext(deviceId).outlet 0, "schedule"

    # Invoked by player. Clear event queues for all device IDs (typicaly
    # a player's modules).
    # 
    # Clear patcher event queue.
    # 
    clearEventQueue: (deviceIds) ->
      for deviceId in deviceIds
        Persistence::deviceContext(deviceId).outlet 0, "clear"
