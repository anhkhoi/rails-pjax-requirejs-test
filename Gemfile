source "https://rubygems.org"

gem "rails", "3.2.8"

# database
gem "mongoid", "~> 3.0.5"
gem "bson_ext", "~> 1.7.0"

# init
gem "foreman"

group :assets do
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "uglifier", ">= 1.0.3"
end

# javascript
gem "jquery-rails"
gem "requirejs-rails", "~> 0.9.0"
gem "pjax_rails", "~> 0.3.3"

# testing
group :development, :test do
  gem "rspec-rails"
  gem "cucumber-rails", require: false
  gem "autotest-rails"
  gem "autotest-fsevent"
  gem "autotest-growl"
end
group :test do
  gem "spork"
  gem "shoulda"
  gem "factory_girl_rails"
  gem "mongoid-rspec"
  gem "vcr"
  gem "webmock"
  gem "database_cleaner"
  gem "capybara", "1.1.2"
  gem "capybara-webkit", "0.12.1"
  gem "selenium-webdriver", "2.24.0"
  gem "email_spec"
  gem "simplecov", require: false
end