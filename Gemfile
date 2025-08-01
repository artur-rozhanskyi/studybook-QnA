source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 6.6'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'active_model_serializers'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'carrierwave'
gem 'carrierwave-base64'
gem 'devise', '~> 4.9', '>= 4.9.4'
gem 'doorkeeper'
gem 'dotenv'
gem 'dotenv-deployment', require: 'dotenv/deployment'
gem 'font_awesome5_rails'
gem 'gon'
gem 'haml-rails'
gem 'jquery-rails', '>= 4.5.0'
gem 'jsbundling-rails'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'pundit'
gem 'rack-cors'
gem 'rails_12factor', group: :production
gem 'responders'
gem 'sidekiq', '~> 7.0'
gem 'sidekiq-scheduler'
gem 'turbo-rails'

group :development, :test do
  gem 'pry-rails'
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'database_cleaner', '~> 2.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'json_spec'
  gem 'launchy'
  gem 'observer'
  gem 'rails-controller-testing'
  gem 'rspec', '~> 3.13'
  gem 'rspec-rails', '~> 8.0.0'
  gem 'shoulda-matchers'
  gem 'webdrivers'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'letter_opener'
  gem 'listen', '~> 3.9'
  gem 'web-console', '>= 3.3.0'

  gem 'capistrano', require: false
  gem 'capistrano3-nginx', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-sidekiq', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
