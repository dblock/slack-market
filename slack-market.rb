ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV']

Dir[File.expand_path('config/initializers', __dir__) + '/**/*.rb'].each do |file|
  require file
end

Mongoid.load! File.expand_path('config/mongoid.yml', __dir__), ENV['RACK_ENV']

require 'slack-ruby-bot'
require 'slack-market/version'
require 'slack-market/service'
require 'slack-market/info'
require 'slack-market/models'
require 'slack-market/api'
require 'slack-market/app'
require 'slack-market/server'
require 'slack-market/commands'
