# 
# logger.coffee: Logging in Max 6
# 
# Copyright 2013 Adam Florin
# 

class Logger
  LOG_PATH = "/../log/loom.log"
  COMPILED_SOURCE_PATH = "/../build/"
  LOG_LEVELS = 
    debug: color: 37
    info: color: 36
    warn: color: 33
    error: color: 31
  ESCAPE_CHAR = String.fromCharCode(27)

  # 
  # 
  constructor: ->
    @initWriteMethods()
    @openFile()
  
  # Metaprogramming convenience functions
  # 
  # Each log level method accepts a splat, which can be
  # any basic JS type: string, error, object, array, number.
  # 
  initWriteMethods: ->
    for level of LOG_LEVELS
      do (level) =>
        @[level] = (objects...) ->
          @write(level, objects)

  # Init File handle
  # 
  # Then immediately close, as File object will NOT re-open later
  # if autowatch reloads source while a File object is open.
  # 
  openFile: ->
    path = Max::patcherDirPath() + LOG_PATH
    @file = new File(path, "write")
    throw "Unable to open log file at #{path}" unless @file.isopen
    @file.close()

  # Log message
  # 
  write: (level, objects) ->
    @file.open()
    throw "Unable to open log file" unless @file.isopen
    @file.position = @file.eof
    @file.writeline(@format(object, level)) for object in objects
    @file.close()

  # Format log line
  # 
  format: (object, level) ->
    msg = switch object?.type()
      when "Object" then JSON.stringify(object)
      when "Error" then @stackTrace(object)
      else object
    @colorize "#{@timestamp()} #{level.toUpperCase()} #{msg}", level

  # Handcode time-to-string formatting
  # 
  timestamp: ->
    now = new Date
    "#{now.getFullYear()}-" +
      "#{(now.getMonth()+1).toZeroPaddedString(2)}-" +
      "#{now.getDate().toZeroPaddedString(2)} " +
      "#{now.getHours().toZeroPaddedString(2)}:" +
      "#{now.getMinutes().toZeroPaddedString(2)}:" +
      "#{now.getSeconds().toZeroPaddedString(2)}." +
      "#{now.getMilliseconds().toZeroPaddedString(3)}"

  # ANSI-style coloring
  # 
  colorize: (line, level) ->
    "#{ESCAPE_CHAR}[#{LOG_LEVELS[level].color}m#{line}#{ESCAPE_CHAR}[0m"

  # Print stack trace, given exception.
  # 
  stackTrace: (exception) ->
    lines = for line in exception.stack.split("\n")[0..-2]
      [all, file, number] = line.match(/@(.+):(\d+)/)
      @guessFunctionName(file, number)
    "#{exception.message}\n" + lines.join("\n")

  # Once CoffeeScript compiler properly generates source maps
  # (https://github.com/jashkenas/coffee-script/issues/2779)
  # we'll be able to provide detailed and accurate stack traces
  # (https://github.com/mozilla/source-map).
  # 
  # Until then, for each line of a stack trace, load the entire
  # source file and guess the name of the anonymous function
  # by just looking at the nearest `function` keyword above.
  # This is not a perfect solution, as it doesn't catch `try`
  # blocks or whatever else JS may put in a stack trace,
  # and it's not at all optimized, but it works for now.
  # 
  # File.writeline() is limited to 32K. Check if readstring is, too.
  # (http://cycling74.com/forums/topic.php?id=35547)
  # 
  guessFunctionName: (file, number) ->
    # load source from file
    path = Max::patcherDirPath() + COMPILED_SOURCE_PATH + file + ".js"
    sourceFile = new File(path, "read")
    throw "Unable to open source file at #{path}" unless sourceFile.isopen
    source = sourceFile.readstring(sourceFile.eof)
    sourceFile.close()

    # scan lines
    sourceLines = source.split("\n")
    for line in [(number-1)..0]
      if functionDefinition = sourceLines[line].match(/(\S+?)[\s=(]+function.*/)
        return functionDefinition[1]

    return "<unknown>"
