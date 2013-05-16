# 
# logger.coffee: Logging in Max 6
# 
# Copyright 2013 Adam Florin
# 

class Logger
  LOG_PATH = "/../log/loom.log"
  COMPILED_SOURCE_PATH = "/../javascript/"
  LOG_LEVELS = 
    debug: color: 37
    info: color: 0
    warn: color: 33
    error: color: 31
  ESCAPE_CHAR = String.fromCharCode(27)
  MAX_CHUNK_SIZE = 32768

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
    msg = switch objectType(object)
      when "Object", "Array" then ":\n" + JSON.stringify(object, null, "  ")
      when "Error" then @stackTrace(object)
      else object
    @colorize "#{@timestamp()} #{level.toUpperCase()} #{msg}", level

  # Handcode time-to-string formatting
  # 
  timestamp: ->
    now = new Date
    "#{now.getFullYear()}-" +
      "#{toZeroPaddedString(now.getMonth()+1, 2)}-" +
      "#{toZeroPaddedString(now.getDate(), 2)} " +
      "#{toZeroPaddedString(now.getHours(), 2)}:" +
      "#{toZeroPaddedString(now.getMinutes(), 2)}:" +
      "#{toZeroPaddedString(now.getSeconds(), 2)}." +
      "#{toZeroPaddedString(now.getMilliseconds(), 3)}"

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
  # Note: it's possible source file didn't load at init, as only one process
  # can open a file handle at once, and there appears to be a race condition.
  # In that case, try to load it again now. Fail gracefully either way
  # (simply logging all functions as <unknown>).
  # 
  guessFunctionName: (file, number) ->
    @loadSourceFile() unless @source?
    if @source? and file.replace(/\.js$/, "") is @sourceFilename
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
  # Note: must read the file in 32K chunks.
  # 
  loadSourceFile: (filename) ->
    @sourceFilename ?= filename
    @source = ""
    path = Max::patcherDirPath() + COMPILED_SOURCE_PATH + @sourceFilename + ".js"
    sourceFile = new File(path, "read")
    if sourceFile.isopen
      size = sourceFile.eof
      while size > 0
        @source += sourceFile.readstring Math.min(size, MAX_CHUNK_SIZE)
        size -= MAX_CHUNK_SIZE
    sourceFile.close()
