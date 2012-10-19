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
    [:web, :app, :db]
  end

  namespace :iptables do
    task :install, roles: iptables_roles, on_no_matching_servers: :continue do
      sudo "apt-get install -y iptables"
      puts " ** installed IPTables firewall.".green
      configure_servers
      puts " ** configured IPTables.".green
      configure_preup
      puts " ** IPTables set to restore on boot.".green
    end
    
    per_server_task :configure_servers, roles: iptables_roles, on_no_matching_servers: :continue do |server, roles|
      puts " ** configuring IPTables for #{server} with roles: #{roles.join(", ")}".yellow
      upload_iptables_config({
        open_ports: open_ports.select do |p|
          (p[:roles] & Array(roles)).size > 0
        end
      })
    end
    
    task :configure_preup, roles: iptables_roles, on_no_matching_servers: :continue do
      destination = "/etc/network/if-pre-up.d/iptables"
      # define the temporary upload location
      tempfile_path = "/tmp/iptables_preup"
      # upload the config to the server
      put("#!/bin/sh\niptables-restore < #{iptables_config_file}\nexit 0\n", tempfile_path, mode: 0600)
      # delete any existing file
      sudo "rm -f #{destination}"
      # move it to the right place
      sudo "mv #{tempfile_path} #{destination}"
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