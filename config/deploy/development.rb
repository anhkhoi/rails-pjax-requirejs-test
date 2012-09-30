set :deploy_via, :copy

# SSH details
key_file = `vagrant ssh-config | grep IdentityFile | awk '{print $2}'`.chomp

ssh_options.merge!({
  user: "vagrant",
  port: 2222,
  keys: key_file
})

# Servers
role :web, "127.0.0.1"
role :app, "127.0.0.1"
role :db,  "127.0.0.1"

# Set services for each role
set :services, {
  nginx: [:web]
}

namespace :vagrant do
  desc "Ensure the connection to Vagrant is working"
  task :verify_connection do
    begin
      capture "whoami"
      puts " ** verified successful connection to Vagrant."
    rescue => e
      abort "Connection to Vagrant failed - #{e.message}"
    end
  end
end

# Ensure we can connect to the Vagrant server first
before "deploy:setup", "vagrant:verify_connection"