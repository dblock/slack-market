IEX::Api.configure do |config|
  config.endpoint = ENV['IEX_API_ENDPOINT'] || 'https://cloud.iexapis.com/v1'
end
