Capistrano::Configuration.instance(:must_exist).load do
  # Update aptitude
  after "deploy:setup", "aptitude:update"

  namespace :aptitude do
    desc "Updates aptitude"
    task :update do
      sudo "apt-get -y -qq update"
    end
  end
end