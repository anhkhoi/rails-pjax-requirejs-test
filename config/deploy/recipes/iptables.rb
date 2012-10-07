require_relative "lib/erb_hash_binding"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # install on deploy
  after "deploy:bootstrap", "iptables:install"

  # Where to store the iptables configuration file (remotely)
  set :iptables_config_file, "/etc/iptables.up.rules"

  # Where to store the iptables configuration templates (locally)
  set :iptables_template_dir, File.join(File.dirname(__FILE__), "templates/iptables")
  
  # loads the user's setting for which roles IPTables is to be installed on
  def iptables_roles
    services[:iptables] || []
  end

  namespace :iptables do
    task :install, roles: iptables_roles do
      sudo "apt-get install -y iptables"
    end
    
    task :configure, roles: iptables_roles do
      upload_iptables_config({
        open_ports: open_ports.select do |p|
          (p.roles & roles).size > 0
        end
      })
    end
  end

  def upload_iptables_config(options)
    # render the file
    data = render_iptables_config(options)
    # define the destination
    destination = iptables_config_file
    # define the temporary upload location
    tempfile_path = "/tmp/iptables_#{File.basename(destination)}"
    # upload the config to the server
    put(data, tempfile_path, mode: 0600)
    # delete any existing file
    sudo "rm -f #{destination}"
    # move it to the right place
    sudo "mv #{tempfile_path} #{destination}"
  end
  
  def render_iptables_config(options)
    # load our template name
    template_name = options.delete(:template) || "default.erb"
    # load the template contents
    template_path = File.join(iptables_template_dir, template_name)
    template_data = File.read(template_path)
    # render the template with the options
    data = ErbHashBinding.new(options).render(template_data)
  end
end