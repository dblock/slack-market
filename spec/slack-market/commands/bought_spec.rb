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
    it 'requires a subscription' do
      expect(message: "#{SlackRubyBot.config.user} bought MSFT",
             user: user.user_id).to respond_with_slack_message(team.subscribe_text)
    end
    context 'subscribed team' do
      let(:team) { Fabricate(:team, subscribed: true) }
      it 'records a buy', vcr: { cassette_name: 'iex/msft' } do
        expect do
          expect(message: "#{SlackRubyBot.config.user} bought MSFT", user: user.user_id).to respond_with_slack_message(
            "#{user.slack_mention} bought Microsoft Corp. (MSFT) at ~$135.69"
          )
        end.to change(Position, :count).by(1)
        position = Position.last
        expect(position.symbol).to eq 'MSFT'
        expect(position.name).to eq 'Microsoft Corp.'
        expect(position.purchased_price_cents).to eq 13569
        expect(position.purchased_at).to_not be nil
      end
      context 'with an owned position' do
        let!(:position) { Fabricate(:position, user: user, name: 'XYZ Corporation', symbol: 'XYZ') }
        it 'does not support multiple buys' do
          allow(Market).to receive(:quotes).with([position.symbol]).and_return([
                                                                                 OpenStruct.new(
                                                                                   symbol: position.symbol, company_name: position.name, latest_price: 123
                                                                                 )
                                                                               ])
          expect do
            expect(message: "#{SlackRubyBot.config.user} bought #{position.symbol}",
                   user: user.user_id).to respond_with_slack_message(
                     "#{user.slack_mention} already holds XYZ Corporation (XYZ)"
                   )
          end.to_not change(Position, :count)
        end
      end
    end
  end
end
