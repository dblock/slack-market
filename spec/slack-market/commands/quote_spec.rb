require 'spec_helper'

describe SlackMarket::Commands::Quote do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  context 'quote', vcr: { cassette_name: 'msft' } do
    it 'returns a quote for MSFT' do
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
    it 'returns a quote for MSFT and YHOO', vcr: { cassette_name: 'msft_yahoo_invalid' } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Microsoft Corporation (MSFT): $50.16',
            title_link: 'http://finance.yahoo.com/q?s=MSFT',
            title: 'Microsoft Corporation (MSFT)',
            text: '$50.16 (-3.54%)',
            color: '#FF0000'
          }
        ]
      )
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        attachments: [
          {
            fallback: 'Yahoo! Inc. (YHOO): $27.97',
            title_link: 'http://finance.yahoo.com/q?s=YHOO',
            title: 'Yahoo! Inc. (YHOO)',
            text: '$27.97 (-4.05%)',
            color: '#FF0000'
          }
        ]
      )
      app.send(:message, client, Hashie::Mash.new(channel: 'channel', text: "How's MSFT or YHOO and INVALID?"))
    end
    it 'does not trigger with a channel ID' do
      expect(client.web_client).to_not receive(:chat_postMessage)
      app.send(:message, client, Hashie::Mash.new(channel: 'channel', text: 'I created <#C04KB5X4D>!'))
    end
  end
end
