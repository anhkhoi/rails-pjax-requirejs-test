require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install redis when setting up the server
  after "deploy:bootstrap", "redis:install"

  # Configure the monit.d config file after install
  after "redis:install", "redis:configure_monit"

  # Configure the logrotate.d config file after install
  after "redis:install", "redis:configure_logrotate"

  _cset(:redis_service_name) { "redis-server" }
  _cset(:redis_roles) { [:kv] }

  namespace :redis do
    desc "Installs redis"
    task :install, roles: fetch(:redis_roles), on_no_matching_servers: :continue do
      sudo "apt-get install -y -qq redis-server"
      puts " ** installed redis."
    end

    desc "Configures Monit to watch redis"
    task :configure_monit, roles: fetch(:redis_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:redis_service_name), {
        process_name: fetch(:redis_service_name),
        pid_file: "/var/run/redis/redis-server.pid",
        start_command: "/etc/init.d/redis-server start",
        stop_command: "/etc/init.d/redis-server stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end

    desc "Configures logrotate to watch redis"
    task :configure_logrotate, roles: fetch(:redis_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config(fetch(:redis_service_name), {
        path: "/var/log/redis/*.log",
        post_rotate: "monit reload #{fetch(:redis_service_name)}"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end

    desc "Start redis"
    task :start, roles: fetch(:redis_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:redis_service_name)
      monit.start_service
    end

    desc "Stop redis"
    task :stop, roles: fetch(:redis_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:redis_service_name)
      monit.stop_service
    end

    desc "Restart redis"
    task :restart, roles: fetch(:redis_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:redis_service_name)
      monit.restart_service
    end
  end
end