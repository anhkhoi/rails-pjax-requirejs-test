# Application options
set :application, "pjax_requirejs_test"

# Source control
set :scm, :git

# Multistage options
set :stages, %w(development)
set :default_stage, "development"

# RVM config
set :rvm_ruby_string, :local

require "capistrano/ext/multistage"
require "bundler/capistrano"
require "rvm/capistrano"

Dir[File.join(File.dirname(__FILE__), "recipes", "*.rb")].each { |f| require f }