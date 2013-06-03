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
  "config/version"
  "utilities/utilities"
  "utilities/number"
  "utilities/logger"
  "persistence/serializable"
  "persistence/persistence"
  "persistence/persisted"
  "loom"
  "loom/player"
  "loom/module"
  "loom/modules/continue"
  "loom/modules/count"
  "loom/modules/echo"
  "loom/modules/follow"
  "loom/modules/impulse"
  "loom/modules/loop"
  "loom/modules/meter"
  "loom/modules/pitch"
  "loom/modules/start"
  "loom/parameter"
  "loom/parameters/gaussian"
  "loom/parameters/numeric"
  "loom/parameters/remote"
  "loom/parameters/pitches"
  "loom/gesture"
  "loom/event"
  "loom/events/done"
  "loom/events/module"
  "loom/events/note"
  "loom/events/parameter"
  "max-for-live/max"
  "max-for-live/live"
  "max-for-live/global"
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
    'coffee-script/max-for-live/ui/gaussian-curve.coffee'
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
  [ "coffee-script/config/#{target}.coffee"].concat(
    "coffee-script/#{file}.coffee" for file in SOURCE_FILES)

# Print results
# 
execOutput = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr
