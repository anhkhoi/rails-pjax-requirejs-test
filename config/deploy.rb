# Application options
set :application, "pjax_requirejs_test"
set :domain, "www.trustindex.com"

# Source control
set :scm, :git

# Multistage options
set :stages, %w(development)
set :default_stage, "development"

# RVM config
set :rvm_type, :system

require "capistrano_colors"
require "capistrano/ext/multistage"
require "bundler/capistrano"
require "rvm/capistrano"
require File.join(File.dirname(__FILE__), "deploy/recipes/lib/ext.rb")

# Bundler config
set :bundle_cmd, "$rvm_path/bin/rvm rvmrc trust load && bundle"
set :bundle_without, [ :darwin, :development, :test ]

namespace :deploy do
  desc "Bootstraps a server with services"
  task :bootstrap do
    # no-op
  end
  
  desc "Ensure the deployment user owns the app dir"
  task :own_app_dir, except: { no_release: true } do
    sudo "chown #{user}:#{user} -R #{deploy_to}"
  end
end

after "deploy:setup", "deploy:own_app_dir"
after "deploy:setup", "deploy:bootstrap"

Dir[File.join(File.dirname(__FILE__), "deploy", "recipes", "*.rb")].each { |f| require f }