define ["controllers/base_controller"], (BaseController) ->

  class GuidesController extends BaseController
    @before_filter "validate_forms", {
      only: ["new", "edit"]
    }

    new: ->
      @log("guides#new")

    edit: ->
      @log("guides#edit")