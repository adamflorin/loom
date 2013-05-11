# 
# persistence.coffee: Mixin enabling simple persistence layer between Loom and
# [js]'s Global and Dict systems.
# 
# Contains a mix of static and instance methods; context should make clear
# which are which.
# 
# Copyright 2013 Adam Florin
# 

class Persistence

  # Return and cache string that we use as a JSON key to organize data.
  # 
  classKey: ->
    @key ?= @constructor.name.toLowerCase()

  # Global
  # 
  # Messages for managing Max [js] objects Global system, which is able to
  # store any JS object, including function references.
  # 
  mixin @, Global:

    # Open up connection to data store
    # 
    connection: ->
      (new Global("loom"))

    # Hybrid getter/setter where each device stores its 'jsthis' so that other
    # devices may access one another's outlets. This is an important aspect of
    # event dispatch, enabling UI events for a number of devices to come from
    # the device that scheduled a gesture, and enabling devices to affect the
    # output of other devices in other players.
    # 
    deviceContext: (deviceId, object) ->
      @connection()["deviceContext"] ?= []
      if object
        @connection()["deviceContext"][deviceId] = object
      else
        @connection()["deviceContext"][deviceId]

  # Dict
  # 
  # Methods for managing Max's [dict] hash-based storage system, which stores
  # JSON-like data, and provides handy debugging tools such as [dict.view].
  # 
  # Some of these methods are static, others operate on the instantiated 'this'.
  # Note that model classes extend Persistence.
  # 
  mixin @, Dict:

    # Static method to create instance of self and populate it with data stored
    # for that ID.
    # 
    # If loadClass is specified in data record, pass it to optional
    # classFromName callback to get the class to instantiate.
    # 
    load: (id, classFromName, constructorArgs) ->
      data = @data id.toString()
      # logger.debug "-> Loading #{@classKey()} #{id}:", data
      loadClass = if data?.loadClass? then classFromName(data.loadClass) else @constructor
      logger.info "Loading previously nonexistant #{loadClass.name} #{id}" if not data?
      new loadClass id, data || {}, constructorArgs

    # Instantiate objects for all stored items.
    # 
    loadAll: ->
      @load(id) for id in @normalizedKeys @allData()
    
    # Invoke instantiated object's serialize method and store the result.
    # 
    save: ->
      data = @serialize()
      # logger.debug "<- Saving #{@classKey()} #{@id}:", data
      @allData().set @id.toString(), @serializeObject(data)

    # Destroy data for this object.
    # 
    destroy: ->
      # logger.debug "X- Destroying #{@classKey()} #{@id}"
      @allData().remove @id.toString()

    # Return deserialized object, given ID.
    # 
    data: (id) ->
      d = @find(id)
      return @deserializeObject d

    # Return dict, given ID. Build if nonexistent.
    # 
    find: (key) ->
      dict = @allData()
      keys = @normalizedKeys dict
      if not keys? or key not in keys
        dict.set(key, new Dict)
      return dict.get(key)

    # Return all existing IDs for this class type.
    # 
    allIds: ->
      @normalizedKeys @allData()

    # Returns true if object for ID exists.
    # 
    exists: (id) ->
      id.toString() in @allIds()

    # Static method to return parent Dict which contains all serialized objects
    # of this class.
    # 
    allData: ->
      new Dict @classKey()
    
    # Utility: Feed Object into Dict structure, recursively.
    # 
    # 'dict' arg is optional, and not passed in recursive calls.
    # 
    # Don't store null values.
    # 
    serializeObject: (object, dict) ->
      dict.clear() if dict?
      dict ?= new Dict
      for key, value of object when value?
        dict.set(
          key, 
          unless value instanceof Object then value else @serializeObject value)
      return dict

    # Utility: Build Object from Dict structure, recursively.
    # 
    # Determine that dict should be built as an Array if all of its keys are
    # contiguous numbers beginning with "0".
    # 
    # If dict is empty, there's no way to determine if it's supposed to be an
    # array or object, so just return null so object can initialize that value.
    # 
    deserializeObject: (dict) ->
      keys = @normalizedKeys dict
      return null if keys.length == 0
      object = new Object
      isArray = true
      lastKey = "-1"
      for key in keys when key?
        value = dict.get(key)
        value = @deserializeObject(value) if objectType(value) is "Dict"
        object[key] = value
        if isArray
          isArray = false if parseInt(key) isnt parseInt(lastKey) + 1
          lastKey = key
      return unless isArray then object else (value for key, value of object)

    # The return value of getkeys() is unreliable, presumably because it was
    # designed for use in Max, not in JS. Return an array here, no matter
    # whether getkeys() returned an array, a single value, or null.
    # 
    normalizedKeys: (dict) ->
      keys = dict.getkeys()
      keys = [] unless keys?
      keys = [keys] unless keys instanceof Array
      return keys
