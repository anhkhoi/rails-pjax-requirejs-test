#= require turbolinks
#= require preload
#= require require
#= require jquery
#= require rails
#= require lib/logger
#= require lib/controller_filter
#= require controllers/base_controller
#= require app

require ["jquery", "app"], ($, App) ->
  $ ->
    window.app = new App($(document))
    window.app.boot()