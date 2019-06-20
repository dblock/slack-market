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
    it 'requires a subscription' do
      expect(message: "#{SlackRubyBot.config.user} sold MSFT", user: user.user_id).to respond_with_slack_message(team.subscribe_text)
    end
    context 'subscribed team' do
      let(:team) { Fabricate(:team, subscribed: true) }
      context 'with an owned position' do
        let!(:position) { Fabricate(:position, purchased_price_cents: 1234, user: user, name: 'Microsoft Corp.', symbol: 'MSFT') }
        it 'records a sell', vcr: { cassette_name: 'iex/msft' } do
          expect(message: "#{SlackRubyBot.config.user} sold MSFT", user: user.user_id).to respond_with_slack_message(
            "#{user.slack_mention} sold Microsoft Corp. at ~$135.69, *MSFT* +90.91% :green_book:"
          )
          position.reload
          expect(position.purchased_price_cents).to eq 1234
          expect(position.purchased_at).to_not be nil
          expect(position.sold_price_cents).to eq 13569
          expect(position.sold_at).to_not be nil
        end
      end
      context 'with an owned position without changes' do
        let!(:position) { Fabricate(:position, purchased_price_cents: 13569.5, user: user, name: 'Microsoft Corp.', symbol: 'MSFT') }
        it 'records a sell without change', vcr: { cassette_name: 'iex/msft_float' } do
          expect(message: "#{SlackRubyBot.config.user} sold MSFT", user: user.user_id).to respond_with_slack_message(
            "#{user.slack_mention} sold Microsoft Corp. at ~$135.69, *MSFT* :blue_book:"
          )
        end
      end
      it 'does not sell an unowned position', vcr: { cassette_name: 'iex/msft' } do
        expect do
          expect(message: "#{SlackRubyBot.config.user} sold MSFT", user: user.user_id).to respond_with_slack_message(
            "#{user.slack_mention} does not hold Microsoft Corp. (MSFT)"
          )
        end.to_not change(Position, :count)
      end
    end
  end
end
