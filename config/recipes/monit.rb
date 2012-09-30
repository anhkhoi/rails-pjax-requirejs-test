require "erb"
require "ostruct"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Install Monit on the server during setup
  after "deploy:setup", "monit:install"
  
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
    task :install do
      # install the service
      sudo "apt-get install -y -qq monit"
      # configure for HTTP access
      configure_http_access
      # start the service
      start
    end
    
    desc "Configures Monit for HTTP access"
    task :configure_http_access do
      # adjust the config file where necessary
      run %Q(
        #{sudo} sed -i -e 's/# set httpd port/set httpd port/' #{monit_config_file};
        #{sudo} sed -i -e 's/#    allow localhost/allow localhost/' #{monit_config_file}
      )
      # ensure the changes were valid
      validate_syntax
    end
    
    desc "Configures Monit"
    task :configure do
      # adjust the config file where necessary
      sudo "sed -i -e 's/  set daemon \\\([0-9]\\\{1,\\\}\\\)/  set daemon #{monit_check_interval}/' #{monit_config_file}"
      # ensure the changes were valid
      validate_syntax
    end
    
    desc "Tell monit to start"
    task :start do
      sudo "/etc/init.d/monit start"
    end
    
    desc "Tell monit to stop"
    task :stop do
      sudo "/etc/init.d/monit stop"
    end
    
    desc "Tell monit to re-read it's configuration files"
    task :reload do
      sudo "monit reload"    
    end
    
    desc "Validates Monit configuration syntax"
    task :validate_syntax do
      sudo "monit -t"
    end
    
    desc "Tell monit to start a service (e.g. `cap monit:start_service process=nginx`)"
    task :start_service do
      sudo "monit start #{config[:process] || ENV["process"] || "all"}"
    end
    
    desc "Tell monit to stop a service (e.g. `cap monit:stop_service process=nginx`)"
    task :stop_service do
      sudo "monit stop #{config[:process] || ENV["process"] || "all"}"
    end
    
    desc "Tell monit to restart a service (e.g. `cap monit:restart_service process=nginx`)"
    task :restart_service do
      sudo "monit restart #{config[:process] || ENV["process"] || "all"}"
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
    tempfile_path = "/tmp/#{File.basename(destination)}"
    # render the template with the options
    data = ErbHashBinding.new(options).render(template_data)
    # upload the config to the server
    put(data, tempfile_path, mode: 0600)
    # delete any existing file
    sudo "rm -f #{destination}"
    # move it to the right place
    sudo "mv #{tempfile_path} #{destination}"
  end
  
  class ErbHashBinding < OpenStruct
    def render(template)
      ERB.new(template).result(binding)
    end
  end
end