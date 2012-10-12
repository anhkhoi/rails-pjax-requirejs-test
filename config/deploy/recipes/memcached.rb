require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install memcached when setting up the server
  after "deploy:bootstrap", "memcached:install"

  # Configure the monit.d config file after install
  after "memcached:install", "memcached:configure_monit"
  
  # Configure the logrotate.d config file after install
  after "memcached:install", "memcached:configure_logrotate"

  # loads the user's setting for which roles memcached is to be installed on
  def memcached_roles
    [:app]
  end
  
  # sets the cap on the memory used by memcache (in mb)
  set :memcached_memory_cap, 128
  
  # sets the location of the config file
  set :memcached_config_file, "/etc/memcached.conf"

  namespace :memcached do
    desc "Installs Memcached"
    task :install, roles: memcached_roles do
      sudo "apt-get install -y -qq memcached"
      puts " ** installed memcached.".green
      # adjust the config file where necessary
      sudo "sed -i -e 's/\\-m \\\([0-9]\\\{1,\\\}\\\)/\\-m #{memcached_memory_cap}/' #{memcached_config_file}"
      puts " ** configured memcached with a #{memcached_memory_cap}mb memory cap.".green
    end
    
    desc "Configures Monit to watch Memcached"
    task :configure_monit, roles: memcached_roles do
      # upload the config file
      upload_monit_config("memcached", {
        process_name: "memcached",
        pid_file: "/var/run/memcached.pid",
        start_command: "/etc/init.d/memcached start",
        stop_command: "/etc/init.d/memcached stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end
    
    desc "Configures logrotate to watch Memcached"
    task :configure_logrotate, roles: memcached_roles do
      # upload the config file
      upload_logrotate_config("memcached", {
        path: "/var/log/memcached.log",
        post_rotate: "monit reload memcached"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
  end
end