require 'spec_helper'

describe SlackMarket::Commands::Quote, vcr: { cassette_name: 'quote' } do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  context 'quote' do
    it 'returns a qote' do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Microsoft Corporation (MSFT): $51.91',
            title_link: 'http://finance.yahoo.com/q?s=MSFT',
            title: 'Microsoft Corporation (MSFT)',
            text: '$51.91 (-0.48%)',
            color: '#FF0000'
          }
        ]
      )
      app.send(:message, client, Hashie::Mash.new(channel: 'channel', text: "How's MSFT?"))
    end
  end
end
