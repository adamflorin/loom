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
  "loom"
  "player"
  "module"
  "modules/blank"
  "modules/continue"
  "modules/impulse"
  "modules/meter"
  "modules/start"
  "event"
  "events/clear"
  "events/note"
  "gesture"
  "global"
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

task "linecount", "Count lines of CoffeeScript", ->
  exec "find coffee/. -name '*.coffee' | xargs wc -l",
    (err, stdout, stderr) ->
      throw err if err
      console.log stdout + stderr
