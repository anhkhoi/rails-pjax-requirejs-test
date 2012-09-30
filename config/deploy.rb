set :application, "pjax_requirejs_test"

# Source control
set :scm, :git
set :deploy_via, :copy

# SSH details
ssh_options.merge!({
  user: "vagrant",
  port: 2222,
  keys: `vagrant ssh-config | grep IdentityFile | awk '{print $2}'`.chomp
})

# Servers
role :web, "127.0.0.1"
role :app, "127.0.0.1"
role :db,  "127.0.0.1"

namespace :deploy do
  desc "Ensure the connection to Vagrant is working..."
  task :verify_vagrant do
    puts capture("whoami")
  end
end