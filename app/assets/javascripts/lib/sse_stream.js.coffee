define "lib/sse_stream", ->

  class SSEStream
    @callback_events = ["open", "message", "close", "error"]
    
    constructor: (@url) ->
      @source = new EventSource(@url)
      @events = {}
      @define_callback_events()
      # call close callbacks on error that's a close
      @on "error", (e) =>
        if e.readyState == EventSource.CLOSED
          @event_method("close")(e)
          
    define_callback_events: ->
      for event_name in @.constructor.callback_events
        @events[event_name] = []
        @source.addEventListener(event_name, @event_method(event_name), false)

    # attaches callbacks to events
    on: (event_name, callback) ->
      @events[event_name].push(callback)
      @

    # returns a method which runs callbacks for an event
    event_method: (event_name) ->
      (e) =>
        for event_method in @events[event_name]
          event_method(e)

    # closes the connection to the server
    close: ->
      @source.close()
      # run close callbacks
      @event_method("close")(null)