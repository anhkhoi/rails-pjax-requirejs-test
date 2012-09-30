Capistrano::Configuration.instance(:must_exist).load do
  # Install Monit on the server during setup
  after "deploy:setup", "monit:install"
  
  # Where to store the monit configuration files
  set :monit_config_dir, "/etc/monit/conf.d/"

  namespace :monit do
    desc "Installs Monit on the server"
    task :install do
      sudo "apt-get install -y -qq monit"
    end
    
    desc "Tell monit to re-read it's configuration files"
    task :reload do
      run "monit reload"    
    end
  end
end