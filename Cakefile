{exec} = require 'child_process'

COFFEE_ARGS = [
  'coffee'
  '--bare'
  '--output'
  'build'
  '--compile'
  '--join'
  'loom-module.js'
]

SOURCE_FILES = [
  "monkeypatch"
  "max"
  "live"
  "logger"
  "player"
  "module"
  "modules/blank"
  "event"
  "events/note"
  "gesture"
  "loom"
]

TEST_ARGS = [
  'mocha'
  '--compilers'
  'coffee:coffee-script'
  '--require'
  'should'
  '--colors'
]

# 
task "build", "Compile CoffeeScript to JavaScript", ->
  exec COFFEE_ARGS.concat("coffee/#{file}.coffee" for file in SOURCE_FILES).join(" "),
    (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr

task "test", "Run tests", ->
  invoke "build"
  exec TEST_ARGS.join(" "),
    (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr
