define "controllers/base_controller", ->

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
  
  class BaseController
    @before_filters = []

    @before_filter = (method, options) ->
      filter = new ControllerFilter(method, options)
      @before_filters.push(filter)
    
    constructor: (@view) ->
      # runs the controller-wide scripts
      @common() if @["common"]
      # runs the action
      @perform_action(@view.data("action"))

    perform_action: (action) ->
      # if there is an action defined, and we have a method
      if action && @[action]
        # run applicable filters
        for filter in @.constructor.before_filters || []
          filter.run(@, action)
        # run the method
        @[action]()
    
    unload: -> # no-op
    
    validate_forms: ->
      require ["rails.validations"], =>
        console.log("filter:validate_forms")
        @view.find("form[data-validate]").validate()