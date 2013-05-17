{exec} = require 'child_process'

COFFEE_ARGS = [
  'coffee'
  '--bare'
  '--output'
  'javascript'
  '--compile'
  '--join'
  'loom-module.js'
]

SOURCE_FILES = [
  "utilities"
  "max"
  "live"
  "logger"
  "loom"
  "persistence"
  "persisted"
  "probability"
  "player"
  "module"
  "modules/continue"
  "modules/count"
  "modules/follow"
  "modules/impulse"
  "modules/meter"
  "modules/pitch"
  "modules/start"
  "parameter"
  "parameters/gaussian"
  "parameters/other"
  "parameters/pitches"
  "event"
  "events/note"
  "events/ui"
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

task "build", "Compile all CoffeeScript to JavaScript", ->
  invoke "build-core"
  invoke "build-ui"

task "sbuild", "Wrap Build command from Sublime Text 2", ->
  invoke "build"

task "build-core", "Compile Loom core CoffeeScript to JavaScript", ->
  exec COFFEE_ARGS.concat(sourceFiles "development").join(" "), execOutput

task "build-ui", "Compile [jsui] CoffeeScript to JavaScript", ->
  uiCoffeeArgs = [
    'coffee'
    '--bare'
    '--output'
    'javascript'
    '--compile'
    'coffee-script/ui/gaussian-curve.coffee'
  ]
  exec uiCoffeeArgs.join(" "), execOutput

task "build-distribution", "Begin manual distribution process", ->
  exec COFFEE_ARGS.concat(sourceFiles "distribution").join(" "), execOutput

task "test", "Run tests", ->
  invoke "build"
  exec TEST_ARGS.join(" "), execOutput

task "linecount", "Count lines of CoffeeScript", ->
  exec "find coffee-script/. -name '*.coffee' | xargs wc -l", execOutput

# Prepare list of sources files.
# 
sourceFiles = (target) ->
  ("coffee-script/#{file}.coffee" for file in SOURCE_FILES).concat(
    "coffee-script/build-targets/#{target}.coffee")

# Print results
# 
execOutput = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr
