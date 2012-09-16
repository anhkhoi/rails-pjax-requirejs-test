desc "Alias for jasmine:spec"
task jasmine: "jasmine:spec"

namespace :jasmine do
  desc "Runs Jasmine specs"
  task spec: :environment do
    system("bundle exec guard-jasmine")
  end
end