IEX::Api.configure do |config|
  config.publishable_token = ENV['IEX_API_PUBLISHABLE_TOKEN'] || 'access-token'
end
