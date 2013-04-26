# 
# monkeypatch.coffee
# 
# Copyright 2013 Adam Florin
# 

# Support homebrew mixins so code for a given class may be visually divided
# into distinct packages.
# 
# Example:
# 
#   class Class
#     @mixin Mixin:
#       method: ->
# 
Function::mixin = (mixins) ->
  for mixinName, mixin of mixins
    @::[name] = method for name, method of mixin

# Utility for logger date formatting.
# 
# Pad integer with leading zeros so that it comes out to (at least) a certain
# number of digits.
# 
Number::toZeroPaddedString = (digits) ->
  zeros =
    for powers in [Math.max(digits-1, 0)..1]
      if this < Math.pow(10, powers) then "0" else break
  zeros.join("") + this

# Utility monkeypatch so we can call .type() on any JS object to get its "class".
# 
Object::type = ->
  Object::toString.call(@).match(/(\S+)]$/)[1]
