source "https://rubygems.org"

gem "rails", "3.2.8"

# Web server
gem "puma"

# Database
gem "mongoid", "~> 3.0.5"
gem "bson_ext", "~> 1.7.0"

# Caching
gem "dalli"
#gem "cache_digests"

# App boot scripts
gem "foreman"

# Workers
gem "sidekiq"

group :assets do
  gem "rails-behaviors", "~> 0.4.1"
  gem "sass-rails",      "~> 3.2.3"
  gem "coffee-rails",    "~> 3.2.1"
  gem "uglifier",        ">= 1.0.3"
  gem "compass-rails"
end

# Javascript frameworks
gem "jquery-rails"
gem "requirejs-rails", "~> 0.9.0"
gem "turbolinks"

# Validation
gem "client_side_validations"

# Silence the asset pipeline
gem "quiet_assets", group: :development

# Security
gem "strong_parameters"

# Deployment
group :development do
  gem "capistrano"
  gem "rvm-capistrano"
  gem "capistrano_colors"
end
gem "turbo-sprockets-rails3" # improves asset pipeline speed

# Testing
group :development, :test do
  # Unit tests
  gem "rspec-rails"
  gem "guard-rspec"
  
  # Acceptance tests
  gem "cucumber-rails", require: false
  gem "guard-cucumber"
  
  # JavaScript specs
  gem "jasminerice"
  gem "guard-jasmine"
  
  # improve Guard performance
  if RUBY_PLATFORM =~ /darwin/i
    gem "rb-fsevent", require: false
  end
end

# useful testing utilities
group :test do
  # Helpers for Mongoid projects
  gem "mongoid-rspec"
  
  # Better syntax for testing emails
  gem "email_spec"
  
  # Fixture replacement
  gem "factory_girl_rails"
  
  # Acceptance test framework
  gem "capybara", "1.1.2"
  gem "capybara-webkit", "0.12.1"
  
  # Handle external HTTP requests
  gem "vcr"
  gem "webmock"
  
  # Resets DB between spec runs
  gem "database_cleaner"
  
  # Test coverage
  gem "simplecov", require: false
  
  # Used by Travis
  gem "rake"
end