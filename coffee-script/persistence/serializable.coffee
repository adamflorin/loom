# 
# serializable.coffee: Mixin for classes which may be serialized.
# 
# Copyright 2013 Adam Florin
# 

class Serializable

  # Declare attributes of this to be serialized.
  # 
  serialized: (keys...) ->
    @serializedKeys = keys

  # Turn serialized JSON into rich objects, as specified by serialized().
  # 
  # Optional serializable param specifies object to act upon. Only used in
  # calls to super.
  # 
  # If present, call data-marshaling callbacks, passing data first and key
  # as optional second argument.
  # 
  # Don't overwrite any property of this if there is one.
  # 
  deserialize: (attributes, callbacks, serializable) ->
    serializable ?= @
    @constructor.__super__?.deserialize?(attributes, callbacks, serializable)
    for key in @serializedKeys
      serializable[key] ?= switch objectType(data = attributes[key])
        when "Array"
          for datum in data
            callbacks?[key]?(datum) || datum
        when "Object"
          object = {}
          for objectKey, datum of data
            object[objectKey] = callbacks?[key]?(datum, objectKey) || datum
          object
        else
          data

  # Serialized keys specified by serialized().
  # 
  # Always include loadClass, in case Persisted needs it to instantiate object.
  # 
  # If this is a subclass, always get super's attributes, too.
  # 
  # If key points to an Object or Array, recursively serialize those elements,
  # too.
  # 
  serialize: (serializable) ->
    serializable ?= @
    serialized = extend(
      @constructor.__super__?.serialize?(serializable) || {},
      loadClass: @constructor.name)
    for key in @serializedKeys
      serialized[key] = switch objectType(data = serializable[key])
        when "Array"
          for datum in data
            datum.serialize?() || datum
        when "Object"
          object = {}
          object[objectKey] = datum.serialize?() for objectKey, datum of data
          object
        else
          data
    return serialized
