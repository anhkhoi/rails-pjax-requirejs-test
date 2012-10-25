Capistrano::Configuration.instance(:must_exist).load do
  # Update aptitude
  before "deploy:bootstrap", "aptitude:update"

  namespace :aptitude do
    desc "Updates aptitude"
    task :update, on_no_matching_servers: :continue do
      sudo "apt-get -y -qq update"
      puts " ** updated aptitude."
    end
  end
end