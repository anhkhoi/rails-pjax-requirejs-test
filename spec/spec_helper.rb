# analyse coverage
require "simplecov"
SimpleCov.start "rails"

# use the test environment
ENV["RAILS_ENV"] ||= "test"

# boot rails
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "rspec/autorun"

# include supporting files from spec/support
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }