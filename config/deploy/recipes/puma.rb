require_relative "monit"
require_relative "initd"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Configure the monit.d config file when setting up the server
  after "deploy:bootstrap", "puma:configure_monit"

  # settings
  _cset(:puma_roles) { :app }
  _cset(:puma_port) { 8080 }
  _cset(:puma_pid_file) { File.join(shared_path, "pids/puma.pid") }
  _cset(:puma_state_file) { File.join(shared_path, "pids/puma.state") }
  _cset(:puma_log_file) { File.join(shared_path, "log/puma.log") }
  _cset(:puma_shell) { capture("which rvm-shell").chomp }
  _cset(:puma_service_name) { "puma" }
  _cset(:puma_sock_file) { File.join(shared_path, "pids/puma.sock") }
  _cset(:puma_wrapper_path) { File.join(shared_path, "script/puma") }

  namespace :puma do
    desc "Configures Monit to watch puma"
    task :configure_monit, roles: lambda { fetch(:puma_roles) }, on_no_matching_servers: :continue do
      create_wrapper
      # use the wrapper in an init.d script
      upload_initd_config(fetch(:puma_service_name), {
        pidfile: fetch(:puma_pid_file),
        daemon: fetch(:puma_wrapper_path),
        path: capture("echo $PATH").chomp
      })
      # upload the config file
      upload_monit_config(fetch(:puma_service_name), {
        process_name: fetch(:puma_service_name),
        pid_file: fetch(:puma_pid_file),
        start_command: "/etc/init.d/#{fetch(:puma_service_name)} start",
        stop_command: "/etc/init.d/#{fetch(:puma_service_name)} stop",
        restart_command: "/etc/init.d/#{fetch(:puma_service_name)} restart"
      })
      # note: can also use `su - myuser -c 'COMMAND'` to run via RVM shell
      # ensure the syntax is valid
      monit.validate_syntax
    end
    
    desc "Creates a wrapper to run Puma"
    task :create_wrapper, roles: lambda { fetch(:puma_roles) }, on_no_matching_servers: :continue do
      wrapper_data = %Q(#!/bin/bash --login
       cd #{current_path}
       rvm rvmrc trust load > /dev/null
       rm -f #{fetch :puma_pid_file} #{fetch :puma_sock_file} #{fetch :puma_state_file}
       bundle exec puma -e #{rails_env} -S #{fetch :puma_state_file} --port=#{fetch :puma_port} --pidfile=#{fetch :puma_pid_file} --bind=unix://#{fetch :puma_sock_file} >> #{fetch :puma_log_file} 2>&1 &
      ).gsub(/^[\s\t]+/, "")
      # ensure we have a wrapper path
      run "mkdir -p #{File.dirname(fetch(:puma_wrapper_path))}"
      # remove the wrapper if already existing
      run "rm -f #{fetch(:puma_wrapper_path)}"
      put(wrapper_data, fetch(:puma_wrapper_path), mode: 0755)
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