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


  _cset(:mongodb_roles) { [:db] }
  _cset(:mongodb_config_file) { "/etc/mongodb.conf" }
  _cset(:mongodb_service_name) { "mongodb" }

  namespace :mongodb do
    desc "Handles pre-requisites of mongodb"
    task :install_prerequisites, roles: fetch(:mongodb_roles) do
      sudo "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
      source = "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen"
      put(source, "/tmp/10gen.list", mode: 0600)
      sudo "mv /tmp/10gen.list /etc/apt/sources.list.d/"
      sudo "apt-get update"
    end
    
    desc "Installs mongodb"
    task :install, roles: fetch(:mongodb_roles), on_no_matching_servers: :continue do
      sudo "apt-get install -y -qq mongodb-10gen"
      puts " ** installed mongodb."
    end

    desc "Configures Monit to watch mongodb"
    task :configure_monit, roles: fetch(:mongodb_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:mongodb_service_name), {
        process_name: fetch(:mongodb_service_name),
        pid_file: "/var/lib/mongodb/mongod.lock",
        start_command: "/etc/init.d/mongodb start",
        stop_command: "/etc/init.d/mongodb stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end

    desc "Configures logrotate to watch MongoDB"
    task :configure_logrotate, roles: fetch(:mongodb_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config(fetch(:mongodb_service_name), {
        path: "/var/log/mongodb/*",
        post_rotate: "monit reload #{fetch(:mongodb_service_name)}"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
    
    desc "Start MongoDB"
    task :start, roles: fetch(:mongodb_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:mongodb_service_name)
      monit.start_service
    end
    
    desc "Stop MongoDB"
    task :stop, roles: fetch(:mongodb_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:mongodb_service_name)
      monit.stop_service
    end
    
    desc "Restart MongoDB"
    task :restart, roles: fetch(:mongodb_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:mongodb_service_name)
      monit.restart_service
    end
  end
end