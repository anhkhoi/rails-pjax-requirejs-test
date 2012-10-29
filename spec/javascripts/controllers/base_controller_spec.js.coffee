define "controllers/base_controller_spec", ["controllers/base_controller"], (BaseController) ->

  describe "BaseController", ->

    describe "an instance", ->
      controller = null
      view = null

      beforeEach ->
        loadFixtures "application"
        view = $(document.body)
        controller = new BaseController(view)
    
      describe "#perform_action", ->
        it "should be defined", ->
          expect(controller.perform_action).toBeDefined()
      
      describe "#view", ->
        it "should return the view passed to the constructor", ->
          expect(controller.view).toEqual(view)