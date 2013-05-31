# 
# loom.coffee: Bootstrap Loom framework.
# 
# Divided into three "mixins": Devices, Observers, Messages.
# 
# Copyright 2013 Adam Florin
# 

# Get a handle to `jsthis` to store in a Global.
# 
thisDeviceContext = @

class Loom

  # Devices
  # 
  # Manage Devices and their respective Players and Modules.
  # 
  mixin @, Devices:

    # Module, event, and parameter classes register themselves here so they
    # can be looked up by name.
    # 
    Modules: {}
    Events: {}
    Parameters: {}

    # Create own module, and player if necessary, unless device is not in rack.
    # Otherwise, destroy.
    # 
    # This is called when device is created or on observeDevices or on script
    # reload.
    # 
    # Note: There's no harm in calling initDevice redundantly.
    # 
    initDevice: ->
      Live::available = yes
      Live::resetCache()
      Persistence::deviceEnvironment Live::deviceId(), "context", thisDeviceContext
      if @deviceIsUsable()
        @initModule jsarguments[1]
        player = Player::load Live::playerId()
        player.refreshModuleIds()
        player.clearGestures()
        player.save()
      else
        @destroyDevice()
        Live::available = yes

    # If device is not in a rack, notify user and disable device.
    # 
    # No longer checking to see if device is in rack with non-Loom devices
    # because it's ambiguous whether so-called non-Loom devices are in fact
    # Loom devices which haven't been initialized yet.
    # 
    # Also check our version against the version of first device used in set.
    # 
    deviceIsUsable : ->
      Max::dismissError()
      if not Live::deviceInRack()
        logger.warn "Module created outside of rack"
        Max::displayError "Please place Loom module in a MIDI Effect Rack."
        return false
      if (otherVersion = @versionIncompatible())?
        logger.warn "Incompatible module version detected"
        Max::displayError "This v#{LOOM_VERSION} module is incompatible with " +
          "v#{otherVersion} modules."
        return false
      return true

    # Make sure the Loom version in this devices matches the others. Just check
    # against first device used in set, giving it special precedence.
    # 
    # Return its version number if it doesn't match.
    # 
    versionIncompatible: ->
      otherDeviceId = Module::allIds()[0]
      if otherDeviceId? and otherDeviceId isnt Live::deviceId()
        otherLoomVersion = @inDeviceContext otherDeviceId,
          (context) -> context.LOOM_VERSION
        return otherLoomVersion if otherLoomVersion isnt LOOM_VERSION

    # Create module of appropriate subclass and save.
    # 
    # Then request that [pattrstorage] dump all param values.
    # 
    initModule: (moduleClassName) ->
      module = @Modules[moduleClassName]::load Live::deviceId()
      alreadyInitializing = module.paramsInitializing
      module.paramsInitializing = true
      module.save()
      unless alreadyInitializing
        @scheduleEvents [module.uiEvent("initParams")]

    # Set module parameter. If Live isn't ready yet (haven't received init)
    # then do nothing.
    # 
    parameter: (name, value...) ->
      if Live::available
        Module::update Live::deviceId(), (module) -> module.set name, value

    # Called when [pattrstorage] dump is complete.
    # 
    paramsInitialized: ->
      if Live::available
        Module::update Live::deviceId(), (module) ->
          module.paramsInitializing = false
      @populateAll()

    # Update module interfaces after player layout changes.
    # 
    # Note: If multiple devices are deleted in one keystroke, some of them will
    # attempt to populate themselves even though they can't, because they do
    # not yet realize that they no longer have access to the LiveAPI. In this
    # particular case, use the isAvailable() call, which crashes in other cases.
    # 
    populateDevice: ->
      if Live::isAvailable()
        Module::update Live::deviceId(), (module) ->
          module.populate()

    # Load every existing module's JS context, and call populateDevice on it.
    # 
    # This may be necessary if current device has just been destroyed, or if
    # anything else has changed that might require a UI re-population.
    # 
    populateAll: ->
      for moduleId in Module::allIds()
        @inDeviceContext moduleId, (context) -> context.Loom::populateDevice()

    # Destroy device.
    # 
    # By the time this is called, LiveAPI is no longer available, and tyring to
    # access it can cause crashes. So unset flag in order to notify other logic.
    # 
    destroyDevice: ->
      Live::available = false
      deviceId = Live::deviceId()
      Persistence::destroyDeviceEnvironment deviceId
      if Module::exists deviceId
        (Module::load deviceId).destroy()
        @removePlayerModule Live::playerId(), deviceId
        @populateAll()

    # Remove module from player. If that was the last module, destroy player.
    # Otherwise, save it. It's possible user is moving multiple modules at once
    # and this is not the last call.
    # 
    # Based on who called this, the Live API may or may not be available, so be
    # careful.
    # 
    removePlayerModule: (playerId, deviceId) ->
      player = Player::load playerId
      player.moduleIds = (id for id in player.moduleIds when id isnt deviceId)
      if player.moduleIds.length > 0
        player.save()
      else
        player.destroy()

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
    # Ignore passed-in now from [when] as it doesn't return different times for
    # the two start events, making them impossible to distinguish.
    # 
    observeTransport: (playing, now) ->
      if Live::available
        if playing is 1
          Persistence::connection().overrideNow =
            if Live::now(true) > @TIME_DELAY_THRESHOLD then 0 else null
          unless Persistence::deviceEnvironment Live::deviceId(), "transportPlaying"
            Persistence::deviceEnvironment Live::deviceId(), "transportPlaying", yes
            Player::update Live::playerId(), (player) -> player.transportStart()
        else
          Persistence::deviceEnvironment Live::deviceId(), "transportPlaying", no
          Player::update Live::playerId(), (player) -> player.clearGestures()

    # Observe when module is added, removed or moved in the chain.
    # Normally, just re-sequence the modules within a given player.
    # 
    # If device has changed players, may have to create or destroy
    # new or old players, respectively, and re-init.
    # 
    # This is also called if an ancestor's name has changed (in case player
    # name menus need to be updated).
    # 
    observeDevices: ->
      if Live::available
        oldPlayerId = Live::detectPlayerChange()
        @initDevice()
        if oldPlayerId? and Player::exists oldPlayerId
          logger.info "Device #{Live::deviceId()} moved from player " +
            "#{oldPlayerId} to #{Live::playerId()}"
          @removePlayerModule(oldPlayerId, Live::deviceId())
        else
          Player::update Live::playerId(), (player) -> player.refreshModuleIds()
        @populateDevice()
    
  # Messages
  # 
  # Loom event scheduling logic, from and to Max.
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
    play: (now) ->
      if Live::transportPlaying()
        Persistence::connection().overrideNow = now
        Player::update Live::playerId(), (player) ->
          player.activatedModuleIds.push Live::deviceId()
          player.play()

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
      if Live::transportPlaying()
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
      outputDeviceIds = []

      @outputFromDevice returnDeviceId, "return" if returnDeviceId?

      for event in events.sort((x, y) -> x.at - y.at)
        @outputFromDevice event.deviceId, event.output()
        outputDeviceIds.push event.deviceId

      for deviceId in unique(outputDeviceIds)
        @outputFromDevice deviceId, "schedule"

    # Invoked by player. Clear event queues for all device IDs (typicaly
    # a player's modules).
    # 
    # Clear patcher event queue.
    # 
    clearEventQueue: (deviceIds) ->
      @outputFromDevice deviceId, "clear" for deviceId in deviceIds

    # Send a message out of any registered Loom [js] object.
    # 
    # Infer outlet by message type. Arrays are events which to be scheduled,
    # so should go out the event outlet (1). Strings are commands, to go out
    # the command outlet (0).
    # 
    outputFromDevice: (deviceId, message) ->
      outletIndex = if typeof message is "string" then 0 else 1
      @inDeviceContext deviceId, (context) -> context.outlet outletIndex, message
      
    # Run a callback in JS context of any Loom device.
    # 
    inDeviceContext: (deviceId, callback) ->
      deviceContext = Persistence::deviceEnvironment deviceId, "context"
      unless not deviceContext?
        callback deviceContext
      else
        logger.warn "Device context not available for ID #{deviceId}"
