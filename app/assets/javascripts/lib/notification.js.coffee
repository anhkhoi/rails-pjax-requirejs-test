define "lib/notification", ->
  
  class NotificationView
    constructor: (image, title, content) ->
      @view = @build_container()
      @set_body(image, title, content)
      
    build_container: ->
      el = $("<div></div>")
      el.addClass("notification")
      el.attr("data-behaviour", "notification")
      el
    
    set_body: (image, title, content) ->
      @append_image(image)
      @append_title(title)
      @append_content(content)
      @append_close_button()
    
    append_image: (path) ->
      image = $("<img />").attr("src", path)
      @view.append(image)
    
    append_title: (title) ->
      title = $("<h1></h1>").text(title)
      @view.append(title)
    
    append_content: (content) ->
      title = $("<div></div>").text(content)
      @view.append(content)
    
    append_close_button: ->
      $("<a></a>").addClass("close").click( =>
        @hide()
      ).appendTo(@view)
    
    show: ->
      $(document.body).append(@view)
      @view.addClass("active")
      @["ondisplay"]() if @["ondisplay"]
    
    hide: ->
      @view.removeClass("active")
      @["onclose"]() if @["onclose"]
      setTimeout( =>
        @view.remove()
        @view = null
      , 2000)

  class NotificationShim
    checkPermission: -> 0
    requestPermission: -> true

    createNotification: (image, title, content) ->
      # set the window title
      set_window_title(title)
      # create the notification element
      notification = new NotificationView(image, title, content)
      # return the notification
      notification

    build_notification: (image, title, content) ->
      if image
        img = $("<img />").atr("src", image)
        el.append(img)
      if title
        heading = $("<h1></h1>").text(title)
        el.append(heading)
      if content
        body = $("<div></div>").text(content)
        el.append(body)
      el
    
    set_window_title: (title) ->
      current_title = window.top.document.title
      window.top.document.title = title
      setTimeout( ->
        if window.top.document.title == title
          window.top.document.title = current_title  
      , 5000)

  class Notification
    @connection = ( ->
      window.webkitNotifications ||
      window.mozNotifications ||
      window.notifications ||
      new NotificationShim()
    )()
    
    @check_permission = ->
      connection.checkPermission()
    
    @request_permission = ->
      connection.requestPermission()
    
    constructor: (image, title, content) ->
      if Notification.check_permission()
        n = Notification.connection.createNotification(image, title, content)
        n.show()
      else
        Notification.request_permission()