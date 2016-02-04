ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV']

Dir[File.expand_path('../config/initializers', __FILE__) + '/**/*.rb'].each do |file|
  require file
end

Mongoid.load! File.expand_path('../config/mongoid.yml', __FILE__), ENV['RACK_ENV']

require 'faye/websocket'
require 'slack-ruby-bot'
require 'slack-market-game/version'
require 'slack-market-game/info'
require 'slack-market-game/models'
require 'slack-market-game/api'
require 'slack-market-game/app'
require 'slack-market-game/server'
require 'slack-market-game/service'
require 'slack-market-game/commands'
