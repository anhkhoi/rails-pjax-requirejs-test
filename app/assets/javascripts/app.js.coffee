define "app", ["jquery"], ($) ->

	class App
		constructor: (@view) ->
			@controllers = new Array()

		boot: ->
			@view.on("page:change", =>
				@page_changed($("[data-controller]"))
			).trigger("page:change")

		unload_controllers: ->
			while controller = @controllers.pop()
				controller.unload()

		page_changed: (controller_views) ->
			@unload_controllers()
			controller_views.each (i,el) =>
				@page_specifics($(el))

		page_specifics: (view) ->
			# unless the view is already initialized
			unless view.data("controller-init")
				# mark as initialized
				view.data("controller-init", true)
				# calculate our controller key
				key = "controllers/#{view.data("controller")}_controller"
				# if we have a file for this controller
				if requirejs.s.contexts._.config.paths[key]
					# load the controller specific module
					require [key], (Controller) =>
						# initialize the controller with the view
						controller = new Controller(view)
						# append it to the active controllers
						@controllers.push(controller)
