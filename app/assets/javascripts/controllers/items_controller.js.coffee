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
      require ["lib/sse_stream"], (SSEStream) =>
        @stream = new SSEStream(window.location.href + "/live")
        @stream.on_message (e) ->
          console.log(e.data)
    
    unload: ->
      console.log("unloading items")
      @stream.close() if @stream