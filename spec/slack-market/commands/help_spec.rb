require 'spec_helper'

describe SlackMarket::Commands::Help do
  let!(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  it 'default' do
    expect(client).to receive(:say).with(channel: 'channel', text: [SlackMarket::Commands::Help::HELP, SlackMarket::INFO].join("\n"))
    expect(client).to receive(:say).with(channel: 'channel', gif: 'help')
    message_command.call(client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} help"))
  end
end
