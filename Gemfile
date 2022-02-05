source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4', '>= 5.2.4.4'
# Use Puma as the app server
gem 'puma', '~> 3.11'
gem 'pg', '>= 0.18', '< 2.0'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'jwt'
gem 'concurrent-ruby', require: 'concurrent'
# scheduler
gem 'whenever'
gem 'rest-client'
# for User authentication
gem 'sorcery', '~> 0.12.0'
gem 'kaminari'
gem 'pry-rails'
gem 'active_model_serializers'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'
gem 'device_detector'

# For Authorizations
gem "pundit"
# For time validations
gem 'validates_timeliness', '~> 5.0.0.alpha3'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'rswag-api'
gem 'rswag-ui'

group :development, :test do
  gem 'faker'
  gem 'rswag-specs'
  gem 'bullet'
end

group :development do
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier'
end

group :test do
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 3.5'
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]