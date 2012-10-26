require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install varnish when setting up the server
  after "deploy:bootstrap", "varnish:install"

  # Configure the monit.d config file after install
  after "varnish:install", "varnish:configure_monit"

  # Configure the logrotate.d config file after install
  after "varnish:install", "varnish:configure_logrotate"

  _cset(:varnish_service_name) { "varnishd" }
  _cset(:varnish_roles) { [:web] }

  # sets the location of the app servers
  set :varnish_proxy_host, "127.0.0.1"
  set :varnish_proxy_port, "8080"

  # sets the location of the config file
  set :varnish_config_file, "/etc/varnish/default.vcl"

  namespace :varnish do
    desc "Installs varnish"
    task :install, roles: lambda { fetch(:varnish_roles) }, on_no_matching_servers: :continue do
      sudo "apt-get install -y -qq varnish"
      puts " ** installed varnish."
      # adjust the config file where necessary
      sudo "sed -i -e 's/    \\.host = \".*\"\\;/    \\.host = \"#{varnish_proxy_host}\"\\;/' #{varnish_config_file}"
      sudo "sed -i -e 's/    \\.port = \".*\"\\;/    \\.port = \"#{varnish_proxy_port}\"\\;/' #{varnish_config_file}"
      puts " ** configured varnish to proxy #{varnish_proxy_host}:#{varnish_proxy_port}."
    end

    desc "Configures Monit to watch varnish"
    task :configure_monit, roles: lambda { fetch(:varnish_roles) }, on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:varnish_service_name), {
        process_name: fetch(:varnish_service_name),
        pid_file: "/var/run/varnishd.pid",
        start_command: "/etc/init.d/varnish start",
        stop_command: "/etc/init.d/varnish stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end

    desc "Configures logrotate to watch Varnish"
    task :configure_logrotate, roles: lambda { fetch(:varnish_roles) }, on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config(fetch(:varnish_service_name), {
        path: "/var/log/varnish/*.log",
        post_rotate: "monit reload #{fetch(:varnish_service_name)}"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
    
    desc "Start Varnish"
    task :start, roles: lambda { fetch(:varnish_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:varnish_service_name)
      monit.start_service
    end
    
    desc "Stop Varnish"
    task :stop, roles: lambda { fetch(:varnish_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:varnish_service_name)
      monit.stop_service
    end
    
    desc "Restart Varnish"
    task :restart, roles: lambda { fetch(:varnish_roles) }, on_no_matching_servers: :continue do
      config[:process] = fetch(:varnish_service_name)
      monit.restart_service
    end
  end
end