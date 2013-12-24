source 'https://rubygems.org'
source 'http://torquebox.org/rubygems/'

# gem 'rails', '~> 4.0'
gem 'rails', git: "git://github.com/RMaksymczuk/rails.git", branch: "4-0-stable"
gem 'rails-api'
gem 'jbuilder', '~> 1.5.0'

gem 'activerecord', '~> 4.0.0'
gem 'activerecord-jdbc-adapter', git: "git@github.com:jruby/activerecord-jdbc-adapter.git", branch: 'master', platform: :jruby
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby

gem 'torquebox', '3.0.1'
gem 'torquebox-server', '3.0.1', require: false
gem 'torquebox-stomp', '3.0.1', require: false
gem 'torquebox-messaging', '3.0.1'

#needed for rails4 upgrade
gem 'activeresource', github: 'rails/activeresource'
gem 'actionpack-action_caching', github: 'rails/actionpack-action_caching'
gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'
gem 'activerecord-session_store'
gem 'rails-observers'
gem 'actionview-encoded_mail_to'
gem 'rails-perftest'
gem 'actionpack-xml_parser', github: 'rails/actionpack-xml_parser'

gem 'nokogiri'
gem 'nori'

gem 'zurb-foundation', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'sass-rails',   '~> 4.0.0'
gem 'uglifier', '>= 1.0.3'

#elasticsearch
gem 'rest-client'
gem 'flex-rails'

gem 'bcrypt-ruby', '~> 3.0.0', require: 'bcrypt'
gem 'amberbit-config'
gem 'jruby-openssl'
gem 'will_paginate', '~> 3.0.5'

#Acts as List for db task positioning
gem 'acts_as_list'

#OmniAuth: Google, GitHub
gem 'omniauth', '~> 1.1.0'
gem 'omniauth-google-oauth2'
gem 'omniauth-github', '~> 1.1.1'




group :test do
  gem 'rspec-rails', git: 'https://github.com/rspec/rspec-rails.git', ref: 'ee3f224c61cac7d4de919a23945418fd07ada7c6'
  gem 'database_cleaner', require: false
  gem 'facon', require: false
  gem 'nullobject', require: false
  gem 'factory_girl_rails', '~> 4.3.0'
  gem 'fakeweb', require: false
  gem 'torquebox-no-op', '3.0.1', require: false
  gem 'timecop', require: false
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'email_spec'
  gem 'capybara-screenshot'
end

group :development, :test do
  gem 'pry'
  gem 'capistrano', require: false
  gem 'capistrano-ext', require: false
  gem 'rvm', require: false
  gem 'rvm-capistrano', require: false
end

group :development do
  gem 'rails-erd'
  gem "letter_opener"
  gem 'letter_opener_web', '~> 1.1.0'
  gem 'brakeman', require: false
end
