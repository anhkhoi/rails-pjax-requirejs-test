define "lib/logger", ->

  class Logger
    @instance = ->
      return @i if @i
      @i = new @()
      @i
  
    constructor: ->
      @logger = console
      @log("Logger::new")
    
    log: (message) ->
      @logger.log(message)