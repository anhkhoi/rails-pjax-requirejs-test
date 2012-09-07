require ["jquery", "jquery-ujs", "app"], ($, ujs, App) ->

	$ ->
		window.app = new App($(document.body))
		window.app.boot()