require 'spec_helper'

describe SlackMarketGame::Commands::Quote, vcr: { cassette_name: 'quote' } do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarketGame::Server.new(team: team) }
  let(:client) { app.send(:client) }
  context 'quote' do
    it 'returns a qote' do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Microsoft Corporation (MSFT): $51.91',
            title: 'Microsoft Corporation (MSFT)',
            text: '$51.91 (-0.48%)',
            color: '#FF0000'
          }
        ]
      )
      app.send(:message, client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} quote msft"))
    end
  end
end
