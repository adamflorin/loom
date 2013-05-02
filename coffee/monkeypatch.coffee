# 
# monkeypatch.coffee
# 
# Copyright 2013 Adam Florin
# 

# Support homebrew mixins so that classes can import other classes as mixins
# or so code for a given class may be visually divided into distinct packages.
# 
# Example:
# 
#   class Class
#     @mixin Mixin:
#       method: ->
# 
# Or:
# 
#   class Mixin
#     method: ->
#   class Class
#     @mixin Mixin
# 
# mixin() will determine which syntax is used (whether argument is a Function
# or an Object).
# 
Function::mixin = (mixins) ->
  mixins = if objectType(mixins) is "Function" then {mixin: mixins::} else mixins
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

# No longer a monkeypatch as patching into Object leaves turds everywhere.
# 
objectType = (object) ->
  Object::toString.call(object).match(/(\S+)]$/)[1]
