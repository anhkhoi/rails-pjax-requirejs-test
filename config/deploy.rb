# Application options
set :application, "pjax_requirejs_test"
set :domain, "www.trustindex.com"

# Source control
set :scm, :git

# Multistage options
set :stages, %w(development)
set :default_stage, "development"

# RVM config
set :rvm_ruby_string, ENV["GEM_HOME"].gsub(/.*\//,"")
set :rvm_type, :system

require "capistrano_colors"
require "capistrano/ext/multistage"
require "bundler/capistrano"
require "rvm/capistrano"
require File.join(File.dirname(__FILE__), "deploy/recipes/lib/ext.rb")

# override RVM shell
set :default_shell, "/bin/bash --login"

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
  
  task :migrate, on_no_matching_servers: :continue do
    # no-op
  end
  
  task :start, on_no_matching_servers: :continue do
    puma.start
    varnish.start
    nginx.start
    sidekiq.start
    mongodb.start
    memcached.start
    elasticsearch.start
  end
  
  task :restart, on_no_matching_servers: :continue do
    puma.restart
    sidekiq.restart
  end
  
  task :stop, on_no_matching_servers: :continue do
    puma.stop
    varnish.stop
    nginx.stop
    sidekiq.stop
    mongodb.stop
    memcached.stop
    elasticsearch.stop
  end
end

after "deploy:setup", "deploy:own_app_dir"
after "deploy:setup", "deploy:bootstrap"

Dir[File.join(File.dirname(__FILE__), "deploy", "recipes", "*.rb")].each { |f| require f }