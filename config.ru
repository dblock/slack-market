$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV']

require 'slack-ruby-bot-server'
require 'slack-market'

SlackRubyBotServer.configure do |config|
  config.server_class = SlackMarket::Server
end

NewRelic::Agent.manual_start

SlackMarket::App.instance.prepare!

Thread.abort_on_exception = true

Thread.new do
  SlackMarket::Service.instance.start_from_database!
  SlackMarket::App.instance.after_start!
end

run Api::Middleware.instance
