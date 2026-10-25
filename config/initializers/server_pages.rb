SlackRubyBotServer.configure do |config|
  config.oauth_version = :v1
  config.server_pages do |pages|
    pages.cache_control = 'private, no-cache'
  end
end
