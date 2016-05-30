require 'spec_helper'

describe SlackMarket::Commands::Bought do
  let(:team) { Fabricate(:team) }
  let(:user) { Fabricate(:user, team: team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  before do
    allow(User).to receive(:find_create_or_update_by_slack_id!).and_return(user)
  end
  context 'bought' do
    it 'records a buy', vcr: { cassette_name: 'msft' } do
      expect do
        expect(message: "#{SlackRubyBot.config.user} bought MSFT", user: user.user_id).to respond_with_slack_message(
          "#{user.slack_mention} bought Microsoft Corporation (MSFT) at ~$51.91"
        )
      end.to change(Position, :count).by(1)
      position = Position.last
      expect(position.symbol).to eq 'MSFT'
      expect(position.name).to eq 'Microsoft Corporation'
      expect(position.purchased_price_cents).to eq 5191
      expect(position.purchased_at).to_not be nil
    end
    context 'with an owned position' do
      let!(:position) { Fabricate(:position, user: user, name: 'XYZ Corporation', symbol: 'XYZ') }
      it 'does not support multiple buys' do
        allow(Market).to receive(:quotes).with([position.symbol]).and_return([
          OpenStruct.new(symbol: position.symbol, name: position.name, last_trade_price: 123)
        ])
        expect do
          expect(message: "#{SlackRubyBot.config.user} bought #{position.symbol}", user: user.user_id).to respond_with_slack_message(
            "#{user.slack_mention} already holds XYZ Corporation (XYZ)"
          )
        end.to_not change(Position, :count)
      end
    end
  end
end
