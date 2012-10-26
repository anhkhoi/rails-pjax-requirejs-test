require_relative "monit"
require_relative "logrotate"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install NGINX when setting up the server
  after "deploy:bootstrap", "nginx:install"
  
  # Configure the monit.d config file after install
  after "nginx:install", "nginx:configure_monit"
  
  # Configure the logrotate.d config file after install
  after "nginx:install", "nginx:configure_logrotate"
  
  _cset(:nginx_roles) { [:web] }
  _cset(:nginx_service_name) { "nginx" }

  # returns the location of the NGINX pid file
  def nginx_pid_file
    capture("cat /etc/nginx/nginx.conf | grep pid | awk '{print $2}'").chomp.gsub(/\;$/, "")
  end

  namespace :nginx do
    desc "Installs NGINX"
    task :install, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      sudo "apt-get install -y -qq nginx"
      puts " ** installed NGINX."
    end
    
    desc "Configures monit to watch NGINX"
    task :configure_monit, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:nginx_service_name), {
        template: "nginx.erb",
        process_name: fetch(:nginx_service_name),
        pid_file: nginx_pid_file,
        start_command: "/etc/init.d/nginx start",
        stop_command: "/etc/init.d/nginx stop",
        max_children: 250,
        max_restarts: 5,
        max_cycles: 5
      })
      # ensure the syntax is valid
      monit.validate_syntax
    end
    
    desc "Configures logrotate to watch NGINX"
    task :configure_logrotate, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_logrotate_config(fetch(:nginx_service_name), {
        path: "/var/log/nginx/*.log",
        post_rotate: "monit reload #{fetch(:nginx_service_name)}",
        create: "0640 www-data adm"
      })
      # ensure the syntax is valid
      logrotate.validate_syntax
    end
    
    desc "Start NGINX"
    task :start, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:nginx_service_name)
      monit.start_service
    end
    
    desc "Stop NGINX"
    task :stop, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:nginx_service_name)
      monit.stop_service
    end
    
    desc "Restart NGINX"
    task :restart, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      config[:process] = fetch(:nginx_service_name)
      monit.restart_service
    end
  end
end