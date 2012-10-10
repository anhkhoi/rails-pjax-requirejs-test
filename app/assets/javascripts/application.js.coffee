#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require controllers/base_controller
#= require app

require ["jquery", "app"], ($, App) ->
	$ ->
		window.app = new App($(document.body))
		window.app.boot()