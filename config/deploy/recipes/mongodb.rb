require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install mongodb when setting up the server
  after "deploy:bootstrap", "mongodb:install"

  # Install requirements for mongodb
  before "mongodb:install", "mongodb:install_prerequisites"

  # Configure the monit.d config file after install
  after "mongodb:install", "mongodb:configure_monit"

  # Configure the logrotate.d config file after install
  after "mongodb:install", "mongodb:configure_logrotate"

  # loads the user's setting for which roles mongodb is to be installed on
  def mongodb_roles
    [:db]
  end

  # sets the location of the config file
  set :mongodb_config_file, "/etc/mongodb.conf"

  namespace :mongodb do
    desc "Handles pre-requisites of mongodb"
    task :install_prerequisites, roles: mongodb_roles do
      sudo "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
      source = "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
      put(source, "/tmp/10gen.list", mode: 0600)
      sudo "mv /tmp/10gen.list /etc/apt/sources.list.d/"
      sudo "apt-get update"
    end
    
    desc "Installs mongodb"
    task :install, roles: mongodb_roles, on_no_matching_servers: :continue do
      sudo "apt-get install -y -qq mongodb-10gen"
      puts " ** installed mongodb."
    end

    desc "Configures Monit to watch mongodb"
    task :configure_monit, roles: mongodb_roles, on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config("mongodb", {
        process_name: "mongodb",
        pid_file: "/var/lib/mongodb/mongod.lock",
        start_command: "/etc/init.d/mongodb start",
        stop_command: "/etc/init.d/mongodb stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end

    desc "Configures logrotate to watch mongodb"
    task :configure_logrotate, roles: mongodb_roles, on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config("mongodb", {
        path: "/var/log/mongodb/*",
        post_rotate: "monit reload mongodb"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
    
    desc "Start MongoDB"
    task :start, roles: mongodb_roles, on_no_matching_servers: :continue do
      config[:process] = "mongodb"
      monit.start_service
    end
    
    desc "Stop MongoDB"
    task :stop, roles: mongodb_roles, on_no_matching_servers: :continue do
      config[:process] = "mongodb"
      monit.stop_service
    end
    
    desc "Restart MongoDB"
    task :restart, roles: mongodb_roles, on_no_matching_servers: :continue do
      config[:process] = "mongodb"
      monit.restart_service
    end
  end
end