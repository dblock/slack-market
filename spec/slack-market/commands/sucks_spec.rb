require 'spec_helper'

describe SlackMarket::Commands::Sucks do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  context 'sucks' do
    it 'when the market is up', vcr: { cassette_name: 'dia_up' } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        text: 'No <@>, market is up, you suck!',
        attachments: [
          {
            title_link: 'http://finance.google.com/q=%5EDJI',
            title: 'Dow Jones Industrial Average (^DJI)',
            color: '#00FF00',
            image_url: '/api/charts/DJI'
          }
        ]
      )
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'market sucks'))
    end
    it 'when the market is down', vcr: { cassette_name: 'dia_down' } do
      expect(client.web_client).to receive(:chat_postMessage).with(
        channel: 'channel',
        as_user: true,
        text: 'Indeed <@>, market sucks!',
        attachments: [
          {
            title_link: 'http://finance.google.com/q=%5EDJI',
            title: 'Dow Jones Industrial Average (^DJI)',
            color: '#FF0000',
            image_url: '/api/charts/DJI'
          }
        ]
      )
      message_command.call(client, Hashie::Mash.new(channel: 'channel', text: 'market sucks'))
    end
  end
end
