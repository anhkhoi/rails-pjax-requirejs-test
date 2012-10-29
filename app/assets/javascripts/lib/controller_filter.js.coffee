define "lib/controller_filter", ->

  class ControllerFilter
    constructor: (@method, @options) ->
    
    run: (controller, action) ->
      if @applicable(action)
        controller[@method]()
    
    applicable: (action) ->
      unless @options
        return true
      if @options.only && @options.only.indexOf(action) < 0
        return false
      if @options.except && @options.except.indexOf(action) > 0
        return false
      return true