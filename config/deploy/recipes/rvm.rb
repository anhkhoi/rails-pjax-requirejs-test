Capistrano::Configuration.instance(:must_exist).load do
  # Install RVM on any server in the config
  before "deploy:setup", "rvm:disable"
  after "deploy:setup", "rvm:install_rvm"
  after "rvm:install_rvm", "rvm:install_ruby"
  after "rvm:install_rvm", "rvm:enable"
  after "after:setup", "rvm:enable"
  
  # Install RVM's requirements before installing it
  before "rvm:install_rvm", "rvm:install_prerequisites"

  def rvm_installed
    @rvm_installed ||= begin
      capture("which rvm") =~ /bin\/rvm/
    rescue
      false
    end
  end

  namespace :rvm do
    desc "Installs RVM requirements"
    task :install_prerequisites do
      packages = %w(build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison)
      sudo "apt-get install -y -qq #{packages.join(" ")}"
    end
    
    desc "Disables RVM usage in Capistrano tasks"
    task :disable do
      unless rvm_installed
        @rvm_shell ||= default_run_options[:shell]
        default_run_options[:shell] = "/bin/bash --login"
      end
    end
  
    desc "Re-enables RVM usage in Capistrano tasks"
    task :enable do
      if @rvm_shell
        set :shell, @rvm_shell
      end
    end
  end
end