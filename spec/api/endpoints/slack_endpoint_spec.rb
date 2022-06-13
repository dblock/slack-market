require 'spec_helper'

describe Api::Endpoints::SlackEndpoint do
  include Api::Test::EndpointTest

  context 'graph' do
    before do
      ENV['SLACK_VERIFICATION_TOKEN'] = 'token'
    end
    it 'parses a good payload and returns correct charts', vcr: { cassette_name: 'iex/msft' } do
      post '/api/slack/action', payload: {
        actions: [{ 'name' => '1M', 'value' => 'MSFT- 1m' }],
        channel: { 'id' => '424242424', 'name' => 'directmessage' },
        token: ENV['SLACK_VERIFICATION_TOKEN'],
        original_message: {
          ts: '1467321295.000010'
        }
      }.to_json
      expect(last_response.status).to eq 201
      payload = JSON.parse(last_response.body)
      expect(payload['attachments'][0]['image_url']).to eq '/api/charts/MSFT.png?p=1M'
    end
    it 'returns an error with a non-matching verification token', vcr: { cassette_name: 'iex/msft' } do
      post '/api/slack/action', payload: {
        actions: [{ 'name' => '1m', 'value' => 'MSFT- 1m' }],
        channel: { 'id' => '424242424', 'name' => 'directmessage' },
        token: 'invalid-token',
        original_message: {
          ts: '1467321295.000010'
        }
      }.to_json
      expect(last_response.status).to eq 401
    end
    after do
      ENV.delete('SLACK_VERIFICATION_TOKEN')
    end
  end
end
