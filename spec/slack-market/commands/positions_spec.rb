require 'spec_helper'

describe SlackMarket::Commands::Positions do
  let(:team) { Fabricate(:team) }
  let(:app) { SlackMarket::Server.new(team: team) }
  let(:client) { app.send(:client) }
  let(:user) { Fabricate(:user) }
  let(:message_command) { SlackRubyBot::Hooks::Message.new }
  context 'positions' do
    it 'creates a user record', vcr: { cassette_name: 'user_info' } do
      expect do
        expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message(
          '<@user> did not take any positions.'
        )
      end.to change(User, :count).by(1)
      user = User.last
      expect(user.user_id).to eq 'user'
      expect(user.user_name).to eq 'username'
    end
    context 'with a position' do
      let!(:position) { Fabricate(:position, user: user, name: 'XYZ Corporation', symbol: 'XYZ') }
      it 'reports position taken' do
        allow(User).to receive(:find_create_or_update_by_slack_id!).and_return(user)
        expect do
          expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message(
            'XYZ'
          )
        end.to_not change(Position, :count)
      end
      it 'only shows open positions' do
        Fabricate(:closed_position, user: user, symbol: 'ZYX')
        allow(User).to receive(:find_create_or_update_by_slack_id!).and_return(user)
        expect do
          expect(message: "#{SlackRubyBot.config.user} positions").to respond_with_slack_message(
            'XYZ'
          )
        end.to_not change(Position, :count)
      end
    end
  end
end
