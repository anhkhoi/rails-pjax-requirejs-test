define "controllers/items_controller", ["controllers/base_controller"], (BaseController) ->
  
  class ItemsController extends BaseController
    @before_filter "validate_forms", {
      only: ["new", "edit"]
    }

    show: ->
      require ["lib/sse_stream"], (SSEStream) =>
        stream = new SSEStream(window.location.href + "/live")
        stream.on "message", (e) =>
          @log(e.data)
        @streams ||= []
        @streams.push(stream)
    
    unload: ->
      @close_streams()
    
    close_streams: ->
      if @streams
        while stream = @streams.pop()
          stream.close()