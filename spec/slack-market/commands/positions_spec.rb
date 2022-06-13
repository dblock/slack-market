require 'spec_helper'

describe SlackMarket::Commands::Positions do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:user) { Fabricate(:user) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  context 'positions' do
    it 'requires a subscription' do
      expect(message: "#{SlackRubyBot.config.user} positions",
             user: user.user_id).to respond_with_slack_message(team.subscribe_text)
    end
    context 'subscribed team' do
      let(:team) { Fabricate(:team, subscribed: true) }
      it 'creates a user record', vcr: { cassette_name: 'slack/user_info' } do
        expect do
          expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message(
            '<@user> does not have any open positions.'
          )
        end.to change(User, :count).by(1)
        user = User.last
        expect(user.user_id).to eq 'user'
        expect(user.user_name).to eq 'username'
      end
      context 'with positions' do
        before do
          allow(User).to receive(:find_create_or_update_by_slack_id!).and_return(user)
        end
        context 'msft', vcr: { cassette_name: 'iex/msft' } do
          it 'up' do
            Fabricate(:position, user: user, name: 'Microsoft Corp.', symbol: 'MSFT', purchased_price_cents: 28_45)
            expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message('*MSFT* +79.03% :green_book:')
          end
          it 'down' do
            Fabricate(:position, user: user, name: 'Microsoft Corp.', symbol: 'MSFT', purchased_price_cents: 228_45)
            expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message('*MSFT* -68.36% :closed_book:')
          end
          it 'unchanged' do
            Fabricate(:position, user: user, name: 'Microsoft Corp.', symbol: 'MSFT', purchased_price_cents: 13569)
            expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message('*MSFT* :blue_book:')
          end
          it 'only shows open positions' do
            Fabricate(:closed_position, user: user, symbol: 'ZYX')
            Fabricate(:position, user: user, name: 'Microsoft Corp.', symbol: 'MSFT', purchased_price_cents: 13569.5)
            expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message('*MSFT* :blue_book:')
          end
        end
        context 'msft and yahoo', vcr: { cassette_name: 'iex/msft_yahoo' } do
          it 'mixed' do
            Fabricate(:position, user: user, name: 'Microsoft Corp.', symbol: 'MSFT', purchased_price_cents: 28_45)
            Fabricate(:position, user: user, name: 'Yahoo!', symbol: 'AABA', purchased_price_cents: 138_46)
            expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message('*MSFT* +79.03% :green_book:, *AABA* -102.19% :closed_book:')
          end
        end
      end
    end
  end
end
