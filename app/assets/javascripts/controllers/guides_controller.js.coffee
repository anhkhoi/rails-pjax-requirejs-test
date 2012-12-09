define "controllers/guides_controller", ["controllers/base_controller"], (BaseController) ->

  class GuidesController extends BaseController
    @before_filter "validate_forms", {
      only: ["new", "edit"]
    }