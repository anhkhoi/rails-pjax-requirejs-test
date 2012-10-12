require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install varnish when setting up the server
  after "deploy:bootstrap", "varnish:install"

  # Configure the monit.d config file after install
  after "varnish:install", "varnish:configure_monit"

  # Configure the logrotate.d config file after install
  after "varnish:install", "varnish:configure_logrotate"

  # loads the user's setting for which roles varnish is to be installed on
  def varnish_roles
    [:web]
  end

  # sets the location of the app servers
  set :varnish_proxy_host, "127.0.0.1"
  set :varnish_proxy_port, "8080"

  # sets the location of the config file
  set :varnish_config_file, "/etc/varnish/default.vcl"

  namespace :varnish do
    desc "Installs varnish"
    task :install, roles: varnish_roles do
      sudo "apt-get install -y -qq varnish"
      puts " ** installed varnish.".green
      # adjust the config file where necessary
      sudo "sed -i -e 's/    \\.host = \".*\"\\;/    \\.host = \"#{varnish_proxy_host}\"\\;/' #{varnish_config_file}"
      sudo "sed -i -e 's/    \\.port = \".*\"\\;/    \\.port = \"#{varnish_proxy_port}\"\\;/' #{varnish_config_file}"
      puts " ** configured varnish to proxy #{varnish_proxy_host}:#{varnish_proxy_port}.".green
    end

    desc "Configures Monit to watch varnish"
    task :configure_monit, roles: varnish_roles do
      # upload the config file
      upload_monit_config("varnish", {
        process_name: "varnishd",
        pid_file: "/var/run/varnishd.pid",
        start_command: "/etc/init.d/varnish start",
        stop_command: "/etc/init.d/varnish stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end

    desc "Configures logrotate to watch varnish"
    task :configure_logrotate, roles: varnish_roles do
      # upload the config file
      upload_logrotate_config("varnish", {
        path: "/var/log/varnish/*.log",
        post_rotate: "monit reload varnish"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
  end
end