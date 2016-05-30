require 'spec_helper'

describe SlackMarket::Commands::Sold do
  let(:team) { Fabricate(:team) }
  let(:user) { Fabricate(:user, team: team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  before do
    allow(User).to receive(:find_create_or_update_by_slack_id!).and_return(user)
  end
  context 'sold' do
    context 'with an owned position' do
      let!(:position) { Fabricate(:position, purchased_price_cents: 1234, user: user, name: 'Microsoft Corporation', symbol: 'MSFT') }
      it 'records a sell', vcr: { cassette_name: 'msft' } do
        expect(message: "#{SlackRubyBot.config.user} sold MSFT", user: user.user_id).to respond_with_slack_message(
          "#{user.slack_mention} sold Microsoft Corporation (MSFT) at ~$51.91"
        )
        position.reload
        expect(position.purchased_price_cents).to eq 1234
        expect(position.purchased_at).to_not be nil
        expect(position.sold_price_cents).to eq 5191
        expect(position.sold_at).to_not be nil
      end
    end
    it 'does not sell an unowned position', vcr: { cassette_name: 'msft' } do
      expect do
        expect(message: "#{SlackRubyBot.config.user} sold MSFT", user: user.user_id).to respond_with_slack_message(
          "#{user.slack_mention} does not hold Microsoft Corporation (MSFT)"
        )
      end.to_not change(Position, :count)
    end
  end
end
