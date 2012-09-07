define ["jquery", "jquery.pjax"], ($) ->

	class App
		constructor: (@view) ->
		
		boot: ->
			@view.find("a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])").pjax("[data-pjax-container]")