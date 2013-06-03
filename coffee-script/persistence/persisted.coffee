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
    loadClass = (if data?.loadClass? then @classFromName?(data.loadClass)) || @constructor
    logger.info "Initializing #{loadClass.name} #{id}" if not data?
    new loadClass id, data || {}, constructorArgs

  # Load and save an object, running the passed-in callback on it in between.
  # 
  update: (id, callback) ->
    if @exists id
      instance = @load(id)
      callback instance
      instance.save()
      return instance

  # Instantiate objects for all stored items.
  # 
  loadAll: ->
    @load id for id in @allIds()
  
  # Invoke instantiated object's serialize method and store the result.
  # 
  save: ->
    @allData()[@id.toString()] = @serialize()

  # Destory data for this object.
  # 
  destroy: ->
    logger.info "Destroying #{@constructor.name} #{@id}"
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
