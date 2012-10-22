define ["controllers/base_controller"], (BaseController) ->
  
  class ItemsController extends BaseController
    @before_filter "validate_forms", {
      only: ["new", "edit"]
    }

    index: ->
      console.log("items#index")

    new: ->
      console.log("items#new")

    edit: ->
      console.log("items#edit")

    show: ->
      console.log("items#show")
    
    unload: ->
      console.log("unloading items")