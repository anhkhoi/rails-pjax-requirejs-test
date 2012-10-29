#= require ../../app/assets/javascripts/preload
#= require ../../app/assets/javascripts/require
#= require config

jasmine.rice.autoExecute = false

require spec_files, (modules...) ->
  jasmine.getEnv().execute()