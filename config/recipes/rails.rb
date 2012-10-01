require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # configure a Rails app logrotate script
  after "deploy:setup", "rails:configure_logrotate"

  namespace :rails do
    task :configure_logrotate do
      # upload the config file
      upload_logrotate_config("rails_app", {
        path: File.join(shared_path, "log/*.log")
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
  end
end