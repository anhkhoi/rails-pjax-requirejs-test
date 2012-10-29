define "controllers/base_controller", ["jquery", "lib/logger", "lib/controller_filter"], ($, Logger, ControllerFilter) ->

  class BaseController
    @before_filters = []

    @before_filter = (method, options) ->
      filter = new ControllerFilter(method, options)
      @before_filters.push(filter)
    
    @logger = Logger.instance()
    
    constructor: (@view) ->
      # runs the controller-wide scripts
      @common() if @["common"]
      # runs the action
      @perform_action(@view.data("action"))

    perform_action: (action) ->
      @log("#{@.constructor.name}##{action}")
      # run applicable filters
      for filter in @.constructor.before_filters || []
        filter.run(@, action)
      # if there is an action defined, and we have a method
      if action && @[action]
        # run the method
        @[action]()
    
    unload: ->
      @log("BaseController#unload")
    
    log: (message) ->
      @.constructor.logger.log(message)
    
    validate_forms: ->
      require ["rails.validations"], =>
        @log("BaseController#validate_forms")
        @view.find("form[data-validate]").validate()