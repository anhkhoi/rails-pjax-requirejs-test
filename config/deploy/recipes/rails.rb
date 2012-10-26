require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # configure a Rails app logrotate script
  after "deploy:bootstrap", "rails:configure_logrotate"
  
  after "bundle:install", "rails:precompile_assets"

  namespace :rails do
    task :configure_logrotate, on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config("rails_app", {
        path: File.join(shared_path, "log/*.log")
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
    
    desc "Compile static assets"
    task :precompile_assets, roles: [:app, :bg], on_no_matching_servers: :continue do
      run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
    end
  end
end