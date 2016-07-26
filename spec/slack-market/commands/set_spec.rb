require 'spec_helper'

describe SlackMarket::Commands::Set do
  let!(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  context 'dollars' do
    it 'requires a subscription' do
      expect(message: "#{SlackRubyBot.config.user} set dollars on").to respond_with_slack_message(team.subscribe_text)
    end
    context 'subscribed team' do
      let(:team) { Fabricate(:team, subscribed: true) }
      it 'shows current value of dollars off' do
        expect(message: "#{SlackRubyBot.config.user} set dollars").to respond_with_slack_message(
          "Dollar signs for team #{team.name} are off."
        )
      end
      it 'shows current value of dollars on' do
        team.update_attributes!(dollars: true)
        expect(message: "#{SlackRubyBot.config.user} set dollars").to respond_with_slack_message(
          "Dollar signs for team #{team.name} are on!"
        )
      end
      it 'enables dollars' do
        team.update_attributes!(dollars: false)
        expect(message: "#{SlackRubyBot.config.user} set dollars on").to respond_with_slack_message(
          "Dollar signs for team #{team.name} are on!"
        )
        expect(client.owner.dollars).to be true
        expect(team.reload.dollars).to be true
      end
      it 'disables dollars' do
        team.update_attributes!(dollars: true)
        expect(message: "#{SlackRubyBot.config.user} set dollars off").to respond_with_slack_message(
          "Dollar signs for team #{team.name} are off."
        )
        expect(client.owner.dollars).to be false
        expect(team.reload.dollars).to be false
      end
    end
  end
  context 'charts' do
    it 'requires a subscription' do
      expect(message: "#{SlackRubyBot.config.user} set charts on").to respond_with_slack_message(team.subscribe_text)
    end
    context 'subscribed team' do
      let(:team) { Fabricate(:team, subscribed: true) }
      it 'shows current value of charts off' do
        team.update_attributes!(charts: false)
        expect(message: "#{SlackRubyBot.config.user} set charts").to respond_with_slack_message(
          "Charts for team #{team.name} are off."
        )
      end
      it 'shows current value of charts on' do
        expect(message: "#{SlackRubyBot.config.user} set charts").to respond_with_slack_message(
          "Charts for team #{team.name} are on!"
        )
      end
      it 'enables charts' do
        team.update_attributes!(charts: false)
        expect(message: "#{SlackRubyBot.config.user} set charts on").to respond_with_slack_message(
          "Charts for team #{team.name} are on!"
        )
        expect(client.owner.charts).to be true
        expect(team.reload.charts).to be true
      end
      it 'disables charts' do
        team.update_attributes!(charts: true)
        expect(message: "#{SlackRubyBot.config.user} set charts off").to respond_with_slack_message(
          "Charts for team #{team.name} are off."
        )
        expect(client.owner.charts).to be false
        expect(team.reload.charts).to be false
      end
    end
  end
end
