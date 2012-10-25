require_relative "lib/erb_hash_binding"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # install on deploy
  after "deploy:bootstrap", "logrotate:install"
  
  # Where to store the logrotate configuration files (remotely)
  set :logrotate_config_dir, "/etc/logrotate.d"
  
  # Where to store the logrotate configuration templates (locally)
  set :logrotate_template_dir, File.join(File.dirname(__FILE__), "templates/logrotate")
  
  namespace :logrotate do
    task :install, on_no_matching_servers: :continue do
      sudo "apt-get install -y logrotate"
      puts " ** installed logrotate."
    end
    
    task :validate_syntax, on_no_matching_servers: :continue do
      sudo "logrotate -f #{logrotate_config_dir}/*"
    end
  end
  
  def upload_logrotate_config(name, options)
    # load our template name
    template_name = options.delete(:template) || "default.erb"
    # load the template contents
    template_path = File.join(logrotate_template_dir, template_name)
    template_data = File.read(template_path)
    # define the destination
    destination = options.delete(:destination) || File.join(logrotate_config_dir, name)
    # define the temporary upload location
    tempfile_path = "/tmp/logrotate_#{File.basename(destination)}"
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