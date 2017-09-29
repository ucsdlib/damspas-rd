source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.8.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '3.2.0'
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
gem 'jbuilder', '~> 2.6.3'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'json', '~> 1.8.6'
gem 'coveralls', '~> 0.8.21', require: false
gem "blacklight_advanced_search"
gem 'sitemap_generator', '~> 5.3.1'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'sqlite3'
  gem 'byebug'
  gem 'rubocop', '~> 0.49.1'
  gem 'rubocop-rspec', '~> 1.15.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.5.0'
  gem 'listen', '~> 3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0.1'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Syslog logging
gem 'syslogger', '~> 1.6.0'
gem 'lograge','~> 0.3.1'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'hyrax', '2.0.0.alpha', git: 'https://github.com/samvera/hyrax.git', ref: '9f117a32a9fdd42a7884c3c5ee59997ad1e8f2d4'
gem 'hydra-role-management'

gem 'nokogiri', '~> 1.7.1'
gem 'sidekiq', '~> 5.0.0'
gem 'rubyXL'

gem 'openseadragon', '~> 0.4.0'

group :development, :test do
  gem 'capybara', '~> 2.14.0'
  gem 'factory_girl_rails', '~> 4.4'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'rspec-mocks', '3.6.0'
  gem 'simplecov', '~> 0.14.1'
  gem 'rails_autolink', '~> 1.1.6'
  gem 'unicorn', '~> 5.3.0'
  gem 'solr_wrapper', '~> 1.0.0'
  gem 'database_cleaner', '~> 1.6.0'
  gem 'rails-controller-testing', '~> 1.0.1'
end

gem 'rsolr', '~> 2.0.1'
gem 'devise', '~> 4.2.1'
gem 'devise-guests', '~> 0.6.0'
group :development, :test do
  gem 'fcrepo_wrapper', '~> 0.8.0'
  gem 'rspec-rails', '~> 3.6.0'
end

group :production do
  gem 'pg'
end
