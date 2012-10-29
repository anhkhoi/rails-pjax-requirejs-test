define "lib/logger", ->

  class LoggerShim
    log: (message) -> # no-op

  class Logger
    @instance = ->
      return @i if @i
      @i = new @()
      @i
  
    constructor: ->
      if window["console"]
        @logger = console
      else
        @logger = new LoggerShim()
    
    log: (message) ->
      @logger.log(message)