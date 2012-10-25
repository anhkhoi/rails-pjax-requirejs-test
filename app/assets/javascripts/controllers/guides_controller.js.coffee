define ["controllers/base_controller"], (BaseController) ->

  class GuidesController extends BaseController
    @before_filter "validate_forms", {
      only: ["new", "edit"]
    }

    new: ->
      console.log("items#new")

    edit: ->
      console.log("items#edit")