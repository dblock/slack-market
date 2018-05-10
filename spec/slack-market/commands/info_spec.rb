require 'spec_helper'

describe SlackMarket::Commands::Info do
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_hook) { SlackRubyBot::Hooks::Message.new }
  context 'subscribed team' do
    let!(:team) { Fabricate(:team, subscribed: true) }
    it 'info' do
      expect(client).to receive(:say).with(channel: 'channel', text: SlackMarket::Commands::Info::INFO)
      expect(client).to receive(:say).with(channel: 'channel')
      message_hook.call(client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} info"))
    end
  end
  context 'non-subscribed team after trial' do
    let!(:team) { Fabricate(:team, created_at: 2.weeks.ago) }
    it 'info' do
      expect(client).to receive(:say).with(channel: 'channel', text: [
        SlackMarket::Commands::Info::INFO,
        [team.send(:trial_expired_text), team.send(:subscribe_team_text)].join(' ')
      ].join("\n"))
      expect(client).to receive(:say).with(channel: 'channel')
      message_hook.call(client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} info"))
    end
  end
  context 'non-subscribed team during trial' do
    let!(:team) { Fabricate(:team, created_at: 1.day.ago) }
    it 'info' do
      expect(client).to receive(:say).with(channel: 'channel', text: [
        SlackMarket::Commands::Info::INFO,
        team.send(:subscribe_team_text)
      ].join("\n"))
      expect(client).to receive(:say).with(channel: 'channel')
      message_hook.call(client, Hashie::Mash.new(channel: 'channel', text: "#{SlackRubyBot.config.user} info"))
    end
  end
end
