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
    info: color: 0
    warn: color: 33
    error: color: 31
  ESCAPE_CHAR = String.fromCharCode(27)

  # 
  # 
  constructor: ->
    @loadSourceFile(jsarguments[0])
    @initWriteMethods()
  
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

  # Open File handle and pass it to `write` callback
  # 
  # Then immediately close, as File object will NOT re-open later
  # if autowatch reloads source while a File object is open.
  # 
  # Return true on success.
  # 
  openFile: (write) ->
    path = Max::patcherDirPath() + LOG_PATH
    file = new File(path, "write")
    fileIsOpen = file.isopen
    write(file) if fileIsOpen
    file.close()
    return fileIsOpen

  # Log message.
  # 
  # If we failed to write, it's probably because another process has locked up
  # the file handle. In that case, re-schedule the write task for a later time.
  # This means that log messages may appear out of order, and that there's
  # a possibility for infinite recursion.
  # 
  write: (level, objects) ->
    wrote = @openFile (file) =>
      file.position = file.eof
      file.writeline(@format(object, level)) for object in objects
    (new Task @write, @, level, objects).schedule() unless wrote

  # Format log line
  # 
  format: (object, level) ->
    msg = switch object?.type?()
      when "Object", "Array" then JSON.stringify(object)
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
  # Note: it's possible source file didn't load at init, as only one process
  # can open a file handle at once, and there appears to be a race condition.
  # In that case, try to load it again now. Fail gracefully either way
  # (simply logging all functions as <unknown>).
  # 
  guessFunctionName: (file, number) ->
    @loadSourceFile() unless @source?
    if @source? and file is @sourceFilename
      sourceLines = @source.split "\n"
      functionName = do ->
        for line in [(number-1)..0]
          if functionDefinition = sourceLines[line].match /(\S+?)[\s=(]+function.*/
            return functionDefinition[1]
    functionName ?= "<unknown>"
    return "  at #{functionName} (#{file}.js:#{number})"

  # Load source file once, and cache it.
  # Initial call will set source filename, too.
  # 
  loadSourceFile: (filename) ->
    @sourceFilename ?= filename
    path = Max::patcherDirPath() + COMPILED_SOURCE_PATH + @sourceFilename + ".js"
    sourceFile = new File(path, "read")
    @source = sourceFile.readstring(sourceFile.eof) if sourceFile.isopen
    sourceFile.close()
