source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'factory_girl', '~> 4.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Deploy with Capistrano
gem 'capistrano', '~> 3.5.0'
gem 'capistrano-rails', '~> 1.1.7'
gem 'capistrano-rbenv', '~> 2.0.4'
gem 'capistrano-bundler', '~> 1.1.3'

gem 'newrelic_rpm', '3.16.0.318'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'hyrax', '0.0.1.alpha', github: 'projecthydra-labs/hyrax'
gem 'flipflop', github: 'jcoyne/flipflop', branch: 'hydra'
gem 'hydra-role-management'

gem 'resque'
gem 'resque-pool'
gem 'sinatra', '~>2.0.0.beta2'

gem 'active-fedora', '11.0.0.rc7'

group :development, :test do
  gem 'capybara', '~> 2.6.0'
  gem 'factory_girl_rails', '~> 4.4'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'rspec-mocks', '3.5.0'
  gem 'simplecov', '~> 0.11.2'
  gem 'rails_autolink', '~> 1.1.6'
  gem 'unicorn', '~> 5.1.0'
  gem 'solr_wrapper', '>= 0.3'
  gem 'database_cleaner', '~> 1.3'
  gem 'rails-controller-testing', '~> 0'
end

gem 'rsolr', '~> 1.0'
gem 'devise'
gem 'devise-guests', '~> 0.5'
group :development, :test do
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
end
