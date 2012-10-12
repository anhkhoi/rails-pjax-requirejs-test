# Application options
set :application, "pjax_requirejs_test"

# Source control
set :scm, :git

# Multistage options
set :stages, %w(development)
set :default_stage, "development"

# RVM config
set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")

require "colored"
require "capistrano/ext/multistage"
require "bundler/capistrano"
require "rvm/capistrano"
require File.join(File.dirname(__FILE__), "deploy/recipes/lib/ext.rb")

namespace :deploy do
  desc "Bootstraps a server with services"
  task :bootstrap do
    # no-op
  end
end

after "deploy:setup", "deploy:bootstrap"

Dir[File.join(File.dirname(__FILE__), "deploy", "recipes", "*.rb")].each { |f| require f }