#= require app

alert("test")

require ["app"], (App) ->

  alert("required")

  describe "App", ->
    it "should have a method called 'boot'", ->
      app = new App()
      expect(app.boot).toBeDefined()
    
    it "should accept a view on init", ->
      loadFixtures "application"
      view = $(document.body)
      app = new App(view)
      expect(app.view).toEqual(view)