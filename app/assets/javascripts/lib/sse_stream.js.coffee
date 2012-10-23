define "lib/sse_stream", ->

  class SSEStream
    constructor: (@url) ->
      @source = new EventSource(@url)
    
    on_message: (callback) ->
      @source.addEventListener("message", callback, false)
      @
    
    close: ->
      console.log("SSE closed connection to #{@url}")
      @source.close()
      @