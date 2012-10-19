require_relative "aptitude"
require_relative "lib/erb_hash_binding"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install Monit on the server during setup
  after "deploy:bootstrap", "monit:install"
  
  # Path to the monitrc file
  set :monit_config_file, "/etc/monit/monitrc"
  
  # Where to store the monit configuration files (remotely)
  set :monit_config_dir, "/etc/monit/conf.d"

  # Where to store the monit configuration templates (locally)
  set :monit_template_dir, File.join(File.dirname(__FILE__), "templates/monit")
  
  # How often (seconds) to check the processes
  set :monit_check_interval, 30

  namespace :monit do
    desc "Installs Monit on the server"
    task :install, on_no_matching_servers: :continue do
      # install the service
      sudo "apt-get install -y -qq monit"
      puts " ** installed monit.".green
      # configure for HTTP access
      configure_http_access
      # configure other options
      configure
      # start the service
      start
    end
    
    desc "Configures Monit for HTTP access"
    task :configure_http_access, on_no_matching_servers: :continue do
      # adjust the config file where necessary
      run %Q(
        #{sudo} sed -i -e 's/# set httpd port/set httpd port/' #{monit_config_file};
        #{sudo} sed -i -e 's/#    allow localhost/allow localhost/' #{monit_config_file}
      )
      # ensure the changes were valid
      validate_syntax
      puts " ** monit configured for HTTP access for `monit status`.".green
    end
    
    desc "Configures Monit"
    task :configure, on_no_matching_servers: :continue do
      # adjust the config file where necessary
      sudo "sed -i -e 's/  set daemon \\\([0-9]\\\{1,\\\}\\\)/  set daemon #{monit_check_interval}/' #{monit_config_file}"
      # ensure the changes were valid
      validate_syntax
      puts " ** monit configured.".green
    end
    
    desc "Tell monit to start"
    task :start, on_no_matching_servers: :continue do
      sudo "/etc/init.d/monit start"
      puts " ** monit started.".green
    end
    
    desc "Tell monit to stop"
    task :stop, on_no_matching_servers: :continue do
      sudo "/etc/init.d/monit stop"
      puts " ** monit stopped.".green
    end
    
    desc "Tell monit to re-read it's configuration files"
    task :reload, on_no_matching_servers: :continue do
      sudo "monit reload"
    end
    
    desc "Validates Monit configuration syntax"
    task :validate_syntax, on_no_matching_servers: :continue do
      sudo "monit -t"
    end
    
    desc "Tell monit to start a service"
    task :start_service, on_no_matching_servers: :continue do
      sudo "monit start #{config[:process] || ENV["process"] || "all"}"
      puts " ** #{config[:process] || ENV["process"] || "all services"} started.".green
    end
    
    desc "Tell monit to stop a service"
    task :stop_service, on_no_matching_servers: :continue do
      sudo "monit stop #{config[:process] || ENV["process"] || "all"}"
      puts " ** #{config[:process] || ENV["process"] || "all services"} stopped.".green
    end
    
    desc "Tell monit to restart a service"
    task :restart_service, on_no_matching_servers: :continue do
      sudo "monit restart #{config[:process] || ENV["process"] || "all"}"
      puts " ** #{config[:process] || ENV["process"] || "all services"} restarted.".green
    end
    
    desc "Tell monit to reload a service"
    task :reload_service, on_no_matching_servers: :continue do
      sudo "monit reload #{config[:process] || ENV["process"] || "all"}"
      puts " ** #{config[:process] || ENV["process"] || "all services"} reloaded.".green
    end
  end
  
  def upload_monit_config(name, options)
    # load our template name
    template_name = options.delete(:template) || "default.erb"
    # load the template contents
    template_path = File.join(monit_template_dir, template_name)
    template_data = File.read(template_path)
    # define the destination
    destination = options.delete(:destination) || File.join(monit_config_dir, "#{name}.conf")
    # define the temporary upload location
    tempfile_path = "/tmp/monit_#{File.basename(destination)}"
    # render the template with the options
    data = ErbHashBinding.new(options).render(template_data)
    # upload the config to the server
    put(data, tempfile_path, mode: 0600)
    # delete any existing file
    sudo "rm -f #{destination}"
    # move it to the right place
    sudo "mv #{tempfile_path} #{destination}"
  end
end