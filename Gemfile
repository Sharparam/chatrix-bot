# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in chatrix-bot.gemspec
gemspec

group :development do
  gem 'pry', '~> 0.10'

  gem 'guard', '~> 2.14'
  gem 'guard-bundler', '~> 2.1', require: false
  gem 'guard-rspec', '~> 4.7', require: false
  gem 'guard-rubocop', '~> 1.2'

  # gem 'chatrix', github: 'Sharparam/chatrix', branch: 'develop'
end

group :test do
  gem 'rake', '~> 10.0'
  gem 'rspec', '~> 3.0'
end

group :development, :test do
  gem 'rubocop', '~> 0.41.0'
end

group :doc do
  gem 'yard', '~> 0.8'
  gem 'redcarpet', '~> 3.3'
end
