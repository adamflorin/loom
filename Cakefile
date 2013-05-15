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

# 
task "build", "Compile CoffeeScript to JavaScript", ->
  exec COFFEE_ARGS.concat("coffee-script/#{file}.coffee" for file in SOURCE_FILES).join(" "),
    execOutput

task "sbuild", "Build command from Sublime Text 2", ->
  invoke "build"
  invoke "build-ui"

task "build-ui", "Compile [jsui] CoffeeScript to JavaScript", ->
  uiCoffeeArgs = [
    'coffee'
    '--bare'
    '--output'
    'javascript'
    '--compile'
    'coffee-script/parameter-ui.coffee'
  ]
  exec uiCoffeeArgs.join(" "), execOutput

task "test", "Run tests", ->
  invoke "build"
  exec TEST_ARGS.join(" "), execOutput

task "linecount", "Count lines of CoffeeScript", ->
  exec "find coffee-script/. -name '*.coffee' | xargs wc -l", execOutput
    
# Print results
# 
execOutput = (err, stdout, stderr) ->
  throw err if err
  console.log stdout + stderr
