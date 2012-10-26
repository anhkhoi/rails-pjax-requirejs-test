require_relative "monit"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Configure the monit.d config file when setting up the server
  after "deploy:bootstrap", "puma:configure_monit"

  # settings
  _cset(:puma_roles) { :app }
  _cset(:puma_port) { 8080 }
  _cset(:puma_pid_file) { File.join(shared_path, "tmp/pids/puma.pid") }
  _cset(:puma_state_file) { File.join(shared_path, "tmp/pids/puma.state") }
  _cset(:puma_log_file) { File.join(shared_path, "log/puma.log") }
  _cset(:puma_shell) { capture("which rvm-shell").chomp }
  _cset(:puma_service_name) { "puma" }

  namespace :puma do
    desc "Configures Monit to watch puma"
    task :configure_monit, roles: lambda { fetch(:puma_roles) }, on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:puma_service_name), {
        process_name: fetch(:puma_service_name),
        pid_file: fetch(:puma_pid_file),
        start_command: "#{fetch :puma_shell} -c 'cd #{current_path} ; $rvm_path/bin/rvm rvmrc trust load ; nohup bundle exec puma -e #{rails_env} -S #{fetch :puma_state_file} --port=#{fetch :puma_port} --pidfile=#{fetch :puma_pid_file} >> #{fetch :puma_log_file} 2>&1 &'",
        stop_command: "#{fetch :puma_shell} -c 'if [ -d #{current_path} ] && [ -f #{fetch :puma_pid_file} ]; then cd #{current_path} ; pumactl --state #{fetch :puma_state_file} stop ; fi ; rm -f #{fetch :puma_pid_file} #{fetch :puma_state_file}'",
        restart_command: "#{fetch :puma_shell} pumactl --state #{fetch :puma_state_file} restart"
      })
      # note: can also use `su - myuser -c 'COMMAND'` to run via RVM shell 
      # ensure the syntax is valid
      monit.validate_syntax
    end
    
    desc "Start Puma"
    task :start, roles: lambda { fetch(:puma_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:puma_service_name)
      monit.start_service
    end
    
    desc "Stop Puma"
    task :stop, roles: lambda { fetch(:puma_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:puma_service_name)
      monit.stop_service
    end
    
    desc "Restart Puma"
    task :restart, roles: lambda { fetch(:puma_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:puma_service_name)
      monit.restart_service
    end
  end
end