require_relative "monit"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Configure the monit.d config file when setting up the server
  after "deploy:bootstrap", "sidekiq:configure_monit"
  
  # settings
  _cset(:sidekiq_roles) { :app }
  _cset(:sidekiq_pid_file) { shared_path.join("tmp/pids/sidekiq.pid") }
  _cset(:sidekiq_config_file) { current_path.join("config/sidekiq.yml") }
  _cset(:sidekiq_log_file) { shared_path.join("log/sidekiq.log") }

  namespace :sidekiq do
    desc "Configures Monit to watch sidekiq"
    task :configure_monit, roles: lambda { fetch(:sidekiq_roles) }, on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config("sidekiq", {
        process_name: "sidekiq",
        pid_file: sidekiq_pid_file,
        start_command: "/usr/local/bin/rvm-shell -c 'cd #{current_path} ; nohup bundle exec sidekiq -e #{rails_env} -C #{fetch :sidekiq_config_file} -P #{fetch :sidekiq_pid_file} >> #{fetch :sidekiq_log_file} 2>&1 &'",
        stop_command: "/usr/local/bin/rvm-shell -c 'if [ -d #{current_path} ] && [ -f #{fetch :sidekiq_pid_file} ]; then cd #{current_path} ; bundle exec sidekiqctl stop #{fetch :sidekiq_pid_file}; fi'"
      })
      # note: can also use `su - myuser -c 'COMMAND'` to run via RVM shell 
      # ensure the syntax is valid
      monit.validate_syntax
    end
  end
end