require 'spec_helper'

describe SlackMarketGame::Commands::Help do
  let!(:team) { Fabricate(:team) }
  let(:app) { SlackMarketGame::Server.new(team: team) }
  let(:client) { app.send(:client) }
  it 'default' do
    expect(client).to receive(:say).with(channel: 'channel', text: [SlackMarketGame::Commands::Help::HELP, SlackMarketGame::INFO].join("\n"))
    expect(client).to receive(:say).with(channel: 'channel', gif: 'help')
    app.send(:message, client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} help"))
  end
end
