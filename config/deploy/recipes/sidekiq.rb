require_relative "monit"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Configure the monit.d config file when setting up the server
  after "deploy:bootstrap", "sidekiq:configure_monit"
  
  # settings
  _cset(:sidekiq_roles) { :app }
  _cset(:sidekiq_pid_file) { File.join(shared_path, "tmp/pids/sidekiq.pid") }
  _cset(:sidekiq_config_file) { File.join(current_path, "config/sidekiq.yml") }
  _cset(:sidekiq_log_file) { File.join(shared_path, "log/sidekiq.log") }
  _cset(:sidekiq_shell) { capture("which rvm-shell").chomp }
  _cset(:sidekiq_service_name) { "sidekiq" }

  namespace :sidekiq do
    desc "Configures Monit to watch sidekiq"
    task :configure_monit, roles: lambda { fetch(:sidekiq_roles) }, on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:sidekiq_service_name), {
        process_name: fetch(:sidekiq_service_name),
        pid_file: fetch(:sidekiq_pid_file),
        start_command: "#{fetch :sidekiq_shell} -c 'cd #{current_path} ; $rvm_path/bin/rvm rvmrc trust load ; nohup bundle exec sidekiq -e #{rails_env} -C #{fetch :sidekiq_config_file} -P #{fetch :sidekiq_pid_file} >> #{fetch :sidekiq_log_file} 2>&1 &'",
        stop_command: "#{fetch :sidekiq_shell} -c 'if [ -d #{current_path} ] && [ -f #{fetch :sidekiq_pid_file} ]; then cd #{current_path} ; bundle exec sidekiqctl stop #{fetch :sidekiq_pid_file}; fi'"
      })
      # note: can also use `su - myuser -c 'COMMAND'` to run via RVM shell 
      # ensure the syntax is valid
      monit.validate_syntax
    end
    
    desc "Start Sidekiq"
    task :start, roles: lambda { fetch(:sidekiq_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:sidekiq_service_name)
      monit.start_service
    end
    
    desc "Stop Sidekiq"
    task :stop, roles: lambda { fetch(:sidekiq_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:sidekiq_service_name)
      monit.stop_service
    end
    
    desc "Restart Sidekiq"
    task :restart, roles: lambda { fetch(:sidekiq_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:sidekiq_service_name)
      monit.restart_service
    end
  end
end