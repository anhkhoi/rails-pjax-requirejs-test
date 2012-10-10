#= require turbolinks
#= require require_config
#= require require
#= require jquery
#= require jquery_ujs
#= require controllers/base_controller
#= require app

require ["jquery", "app"], ($, App) ->
  $ ->
    window.app = new App($(document))
    window.app.boot()