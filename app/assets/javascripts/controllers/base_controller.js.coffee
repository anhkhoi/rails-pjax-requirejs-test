define ->
  
  class BaseController
    constructor: (@view) ->
      # runs the controller-wide scripts
      @common() if @["common"]
      # runs the action
      @perform_action(@view.data("action"))

    perform_action: (action) ->
      # if there is an action defined, and we have a method
      if action && @[action]
        # run the method
        @[action]()