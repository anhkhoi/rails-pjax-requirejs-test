set :deploy_via, :copy
set :copy_remote_dir, "/u/apps/#{application}/builds"
set :repository, "."
set :user, "vagrant"
set :domain, "trustindex.vm"
set :rails_env, "production"

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
role :bg,  "127.0.0.1"
role :kv,  "127.0.0.1"

# Set open ports
set :open_ports, [
  { service: :ssh, access: :wan, roles: [ :web, :app, :db ] },
  { number: 80, access: :wan, roles: [ :web ] },
  { number: 443, access: :wan, roles: [ :web ] },
  { number: 6379, access: :wan, roles: [ :kv ] },
  { number: 27017, access: :wan, roles: [ :db ] }
]

namespace :vagrant do
  desc "Ensure the connection to Vagrant is working"
  task :verify_connection do
    begin
      capture "whoami"
      puts "  * verified successful connection to Vagrant."
    rescue => e
      abort "*** Connection to Vagrant failed - #{e.message}"
    end
  end
end

# Ensure we can connect to the Vagrant server first
before "deploy:setup", "vagrant:verify_connection"

namespace :deploy do
  desc "Makes our builds directory"
  task :mk_builds_dir, except: { no_release: true } do
    test_file = File.join(copy_remote_dir, "test")
    sudo "mkdir -p #{copy_remote_dir}"
    sudo "chmod 0700 -R #{copy_remote_dir}"
    sudo "chown #{user}:#{user} -R #{copy_remote_dir}"
    run "touch #{test_file}; rm #{test_file}"
  end
  
  desc "Deletes any remaining builds"
  task :empty_builds_dir, except: { no_release: true } do
    run "rm -rf #{copy_remote_dir}/*"
  end
end

# Ensure we have our builds dir
after "vagrant:verify_connection", "deploy:mk_builds_dir"
# Ensure it's empty after deploy
after "deploy", "deploy:empty_builds_dir"