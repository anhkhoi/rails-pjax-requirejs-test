define ["controllers/base_controller"], (BaseController) ->
  
  class ItemsController extends BaseController
    index: ->
      console.log("items#index")
    new: ->
      console.log("items#new")