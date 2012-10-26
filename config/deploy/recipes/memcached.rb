require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install memcached when setting up the server
  after "deploy:bootstrap", "memcached:install"

  # Configure the monit.d config file after install
  after "memcached:install", "memcached:configure_monit"
  
  # Configure the logrotate.d config file after install
  after "memcached:install", "memcached:configure_logrotate"
  
  _cset(:memcached_service_name) { "memcached" }
  _cset(:memcached_roles) { [:app] }
  _cset(:memcached_memory_cap) { 128 }
  _cset(:memcached_config_file) { "/etc/memcached.conf" }

  namespace :memcached do
    desc "Installs Memcached"
    task :install, roles: fetch(:memcached_roles), on_no_matching_servers: :continue do
      sudo "apt-get install -y -qq memcached"
      puts " ** installed memcached."
      # adjust the config file where necessary
      sudo "sed -i -e 's/\\-m \\\([0-9]\\\{1,\\\}\\\)/\\-m #{fetch(:memcached_memory_cap)}/' #{fetch(:memcached_config_file)}"
      puts " ** configured memcached with a #{fetch(:memcached_memory_cap)}mb memory cap."
    end
    
    desc "Configures Monit to watch Memcached"
    task :configure_monit, roles: fetch(:memcached_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:memcached_service_name), {
        process_name: fetch(:memcached_service_name),
        pid_file: "/var/run/memcached.pid",
        start_command: "/etc/init.d/memcached start",
        stop_command: "/etc/init.d/memcached stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end
    
    desc "Configures logrotate to watch Memcached"
    task :configure_logrotate, roles: fetch(:memcached_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config(fetch(:memcached_service_name), {
        path: "/var/log/memcached.log",
        post_rotate: "monit reload #{fetch(:memcached_service_name)}"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
    
    desc "Start Memcached"
    task :start, roles: fetch(:memcached_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:memcached_service_name)
      monit.start_service
    end
    
    desc "Stop Memcached"
    task :stop, roles: fetch(:memcached_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:memcached_service_name)
      monit.stop_service
    end
    
    desc "Restart Memcached"
    task :restart, roles: fetch(:memcached_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:memcached_service_name)
      monit.restart_service
    end
  end
end