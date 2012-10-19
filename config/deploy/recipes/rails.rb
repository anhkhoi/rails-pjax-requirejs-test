require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # configure a Rails app logrotate script
  after "deploy:bootstrap", "rails:configure_logrotate"

  namespace :rails do
    task :configure_logrotate, on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config("rails_app", {
        path: File.join(shared_path, "log/*.log")
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
  end
end