define ["controllers/base_controller"], (BaseController) ->
  
  class ItemsController extends BaseController
    @before_filter "validate_forms", {
      only: ["new", "edit"]
    }

    index: ->
      @log("items#index")

    new: ->
      @log("items#new")

    edit: ->
      @log("items#edit")

    show: ->
      @log("items#show")
      require ["lib/sse_stream"], (SSEStream) =>
        stream = new SSEStream(window.location.href + "/live")
        stream.on "message", (e) =>
          @log(e.data)
        @streams ||= []
        @streams.push(stream)
    
    unload: ->
      @log("items:unload")
      @close_streams()
    
    close_streams: ->
      if @streams
        while stream = @streams.pop()
          stream.close()