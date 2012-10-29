define "app_spec", ["app"], (App) ->

  describe "App", ->

    describe "#boot", ->
      it "should have a method called 'boot'", ->
        app = new App()
        expect(app.boot).toBeDefined()
    
    describe "::new", ->
      it "should accept a view", ->
        loadFixtures "application"
        view = $(document.body)
        app = new App(view)
        expect(app.view).toEqual(view)
    
    describe "::controllers", ->
      it "should have a controller definition for each controller", ->
        controllers = [
          "controllers/base_controller",
          "controllers/items_controller"
        ]
        for controller in controllers
          expect(App.controllers).toContain(controller)