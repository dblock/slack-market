require 'spec_helper'

describe SlackMarket::Commands::Help do
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_hook) { SlackRubyBot::Hooks::Message.new }
  context 'premium team' do
    let!(:team) { Fabricate(:team, premium: true) }
    it 'help' do
      expect(client).to receive(:say).with(channel: 'channel', text: [SlackMarket::Commands::Help::HELP, SlackMarket::INFO].join("\n"))
      expect(client).to receive(:say).with(channel: 'channel', gif: 'help')
      message_hook.call(client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} help"))
    end
  end
  context 'non-premium team' do
    let!(:team) { Fabricate(:team) }
    it 'help' do
      expect(client).to receive(:say).with(channel: 'channel', text: [SlackMarket::Commands::Help::HELP, SlackMarket::INFO, team.upgrade_text].join("\n"))
      expect(client).to receive(:say).with(channel: 'channel', gif: 'help')
      message_hook.call(client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} help"))
    end
  end
end
