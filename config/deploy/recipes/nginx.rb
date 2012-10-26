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
  _cset(:nginx_pid_file) { "/var/run/nginx.pid" }
  _cset(:nginx_template_dir) { File.join(File.dirname(__FILE__), "templates/nginx") }
  _cset(:nginx_config_file) { "/etc/nginx/nginx.conf" }
  _cset(:nginx_site_file) { "/etc/nginx/sites-enabled/#{application}" }

  namespace :nginx do
    desc "Installs NGINX"
    task :install, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      sudo "apt-get install -y -qq nginx"
      puts " ** installed NGINX."
    end
    
    desc "Configures NGINX"
    task :configure, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      upload_template({
        template: File.join(fetch(:nginx_template_dir), "nginx.erb"),
        destination: fetch(:nginx_config_file),
        data: {
          pidfile: fetch(:nginx_pid_file)
        }
      })
      
      upload_template({
        template: File.join(fetch(:nginx_template_dir), "site.erb"),
        destination: fetch(:nginx_site_file),
        data: {
          domain: domain,
          current_path: current_path,
          shared_path: shared_path,
          puma_sock_file: fetch(:puma_sock_file),
        }
      })
      
      sudo "rm -f /etc/nginx/sites-enabled/default"
      
      puts " ** configured NGINX."
    end
    
    desc "Configures monit to watch NGINX"
    task :configure_monit, roles: fetch(:nginx_roles), on_no_matching_servers: :continue do
      # upload the config file
      upload_monit_config(fetch(:nginx_service_name), {
        template: "nginx.erb",
        process_name: fetch(:nginx_service_name),
        pid_file: fetch(:nginx_pid_file),
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
  
  def upload_template(options)
    # load the template contents
    template_data = File.read(options[:template])
    # define the temporary upload location
    tempfile_path = "/tmp/nginx_#{File.basename(options[:destination])}"
    # render the template with the options
    data = ErbHashBinding.new(options[:data]).render(template_data)
    # upload the config to the server
    put(data, tempfile_path, mode: options[:mode] || 0600)
    # delete any existing file
    sudo "rm -f #{options[:destination]}"
    # move it to the right place
    sudo "mv #{tempfile_path} #{options[:destination]}"
  end
end