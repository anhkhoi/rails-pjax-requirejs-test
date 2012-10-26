require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install elasticsearch when setting up the server
  after "deploy:bootstrap", "elasticsearch:install"

  # Install requirements for elasticsearch
  before "elasticsearch:install", "elasticsearch:install_prerequisites"

  # Configure the monit.d config file after install
  after "elasticsearch:install", "elasticsearch:configure_monit"

  # Configure the logrotate.d config file after install
  after "elasticsearch:install", "elasticsearch:configure_logrotate"

  _cset(:elasticsearch_version) { "0.19.11" }
  _cset(:elasticsearch_package) { "https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-#{fetch(:elasticsearch_version)}.deb" }
  _cset(:elasticsearch_roles) { [:web] }
  _cset(:elasticsearch_config_file) { "/etc/elasticsearch.conf" }
  _cset(:elasticsearch_service_name) { "elasticsearch" }

  namespace :elasticsearch do
    desc "Handles pre-requisites of elasticsearch"
    task :install_prerequisites, roles: fetch(:elasticsearch_roles) do
      sudo "apt-get install -y openjdk-7-jre"
      jvms = capture("ls -d -1 /usr/lib/jvm/*")
      if jvms =~ /^.*\/java\-7\-openjdk$/
        # no-op (already exists
      elsif jvms =~ /^(.*\/java\-7\-openjdk\-(amd64|i386))$/
        sudo "ln -s #{$1} /usr/lib/jvm/java-7-openjdk"
      else
        abort "Unable to find JVM"
      end
    end

    desc "Installs elasticsearch"
    task :install, roles: fetch(:elasticsearch_roles), on_no_matching_servers: :continue do
      sudo "wget #{fetch(:elasticsearch_package)} -q -O /tmp/elasticsearch.deb"
      sudo "dpkg -i /tmp/elasticsearch.deb"
      puts " ** installed elasticsearch."
    end

    desc "Configures Monit to watch elasticsearch"
    task :configure_monit, roles: fetch(:elasticsearch_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:elasticsearch_service_name), {
        process_name: fetch(:elasticsearch_service_name),
        pid_file: "/var/run/elasticsearch.pid",
        start_command: "/etc/init.d/elasticsearch start",
        stop_command: "/etc/init.d/elasticsearch stop"
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end

    desc "Configures logrotate to watch elasticsearch"
    task :configure_logrotate, roles: fetch(:elasticsearch_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config(fetch(:elasticsearch_service_name), {
        path: "/var/log/elasticsearch/*",
        post_rotate: "monit reload #{fetch(:elasticsearch_service_name)}"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end

    desc "Start Elasticsearch"
    task :start, roles: fetch(:elasticsearch_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:elasticsearch_service_name)
      monit.start_service
    end

    desc "Stop Elasticsearch"
    task :stop, roles: fetch(:elasticsearch_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:elasticsearch_service_name)
      monit.stop_service
    end

    desc "Restart Elasticsearch"
    task :restart, roles: fetch(:elasticsearch_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:elasticsearch_service_name)
      monit.restart_service
    end
  end
end