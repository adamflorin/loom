# 
# persisted.coffee: Base class for persisted models.
# Mix in CRUD methods for models to be persisted in Globals.
# 
# Some of these methods are static, others operate on the instantiated 'this'.
# Loosely based on ActiveRecord.
# 
# Keep IDs numbers when in memory, but turn them into strings to function as
# keys in Global object.
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
  # If loadClass is specified in data record, pass it to classFromName method
  # to look up which subclass of this class to instantiate.
  # 
  load: (id, constructorArgs) ->
    data = @allData()[id.toString()]
    # logger.debug "-> Loading #{@classKey()} #{id}:", data
    loadClass = (if data?.loadClass? then @classFromName?(data.loadClass)) || @constructor
    logger.info "Loading previously nonexistant #{loadClass.name} #{id}" if not data?
    new loadClass id, data || {}, constructorArgs

  # Load and save an object, running the passed-in callback on it in between.
  # 
  update: (id, callback) ->
    instance = @load(id)
    callback instance
    instance.save()

  # Instantiate objects for all stored items.
  # 
  loadAll: ->
    @load parseInt(id) for id in @allIds()
  
  # Invoke instantiated object's serialize method and store the result.
  # 
  save: ->
    data = @serialize()
    # logger.debug "<- Saving #{@classKey()} #{@id}:", data
    @allData()[@id.toString()] = data

  # Destory data for this object.
  # 
  destroy: ->
    # logger.debug "X- Destroying #{@classKey()} #{@id}"
    delete @allData()[@id.toString()]

  # Static method to return complete array of all elements.
  # 
  allData: ->
    Persistence::connection()[@classKey()] ?= {}

  # Return all existing IDs for this class type.
  # 
  allIds: ->
    parseInt id for id of @allData()
  
  # Returns true if object for ID exists.
  # 
  exists: (id) ->
    id in @allIds()
