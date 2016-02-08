require 'spec_helper'

describe SlackMarket::Commands::Set do
  let!(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  it 'gives help' do
    expect(message: "#{SlackRubyBot.config.user} set").to respond_with_slack_message(
      'Missing setting, eg. _set dollars on_.'
    )
  end
  context 'dollars' do
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
      expect(client.team.dollars).to be true
      expect(team.reload.dollars).to be true
    end
    it 'disables dollars' do
      team.update_attributes!(dollars: true)
      expect(message: "#{SlackRubyBot.config.user} set dollars off").to respond_with_slack_message(
        "Dollar signs for team #{team.name} are off."
      )
      expect(client.team.dollars).to be false
      expect(team.reload.dollars).to be false
    end
  end
end
