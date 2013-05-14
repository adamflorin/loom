# 
# persisted.coffee: Base class for persisted models.
# Mix in CRUD methods for models to be persisted in Globals. (Actually, use
# inheritence, so that subclasses may properly instantiate themselves on `load`.)
# 
# Some of these methods are static, others operate on the instantiated 'this'.
# Loosely based on ActiveRecord.
# 
# Copyright 2013 Adam Florin
# 

class Persisted

  # Return and cache string that we use as a JSON key to organize data.
  # 
  classKey: ->
    @key ?= @constructor.name.toLowerCase()

  # Static method to create instance of self and populate it with data stored
  # for that ID.
  # 
  # If loadClass is specified in data record, pass it to optional
  # classFromName callback to get the class to instantiate.
  # 
  load: (id, classFromName, constructorArgs) ->
    data = @allData()[id]
    # logger.debug "-> Loading #{@classKey()} #{id}:", data
    loadClass = if data?.loadClass? then classFromName(data.loadClass) else @constructor
    logger.info "Loading previously nonexistant #{loadClass.name} #{id}" if not data?
    new loadClass id, data || {}, constructorArgs

  # Instantiate objects for all stored items.
  # 
  loadAll: ->
    allData = @allData()
    new @constructor id, allData[id] for id of allData
  
  # Invoke instantiated object's serialize method and store the result.
  # 
  save: ->
    data = @serialize()
    # logger.debug "<- Saving #{@classKey()} #{@id}:", data
    @allData()[@id] = data

  # Destory data for this object.
  # 
  destroy: ->
    # logger.debug "X- Destroying #{@classKey()} #{@id}"
    @allData()[@id] = null

  # Static method to return complete array of all elements.
  # 
  allData: ->
    Persistence::connection()[@classKey()] ?= []

  # Return all existing IDs for this class type.
  # 
  allIds: ->
    parseInt id for id of @allData()
  
  # Returns true if object for ID exists.
  # 
  exists: (id) ->
    id in @allIds()
