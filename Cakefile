{exec} = require 'child_process'

COFFEE_ARGS = [
  '--bare'
  '--output'
  'build'
  '--compile'
  '--join'
  'player.js'
]

SOURCE_FILES = [
  "max"
  "logger"
  "player"
  "loom"
]

# 
task 'build', 'Compile CoffeeScript to JavaScript', ->
  exec "coffee " + COFFEE_ARGS.concat("coffee/#{file}.coffee" for file in SOURCE_FILES).join(" "),
    (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr
