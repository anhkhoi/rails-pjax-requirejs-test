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
        stream = new SSEStream(window.location.href + "/live")
        stream.on "message", (e) ->
          console.log(e.data)
        @streams ||= []
        @streams.push(stream)
    
    unload: ->
      console.log("unloading items")
      @close_streams()
    
    close_streams: ->
      if @streams
        while stream = @streams.pop()
          stream.close()