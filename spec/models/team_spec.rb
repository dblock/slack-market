require 'spec_helper'

describe Team do
  context '#find_or_create_from_env!' do
    before do
      ENV['SLACK_API_TOKEN'] = 'token'
    end
    context 'team', vcr: { cassette_name: 'team_info' } do
      it 'creates a team' do
        expect { Team.find_or_create_from_env! }.to change(Team, :count).by(1)
        team = Team.first
        expect(team.team_id).to eq 'T04KB5WQH'
        expect(team.name).to eq 'dblock'
        expect(team.domain).to eq 'dblockdotorg'
        expect(team.token).to eq 'token'
      end
    end
    after do
      ENV.delete 'SLACK_API_TOKEN'
    end
  end
  context '#purge!' do
    let!(:active_team) { Fabricate(:team) }
    let!(:inactive_team) { Fabricate(:team, active: false) }
    let!(:inactive_team_a_week_ago) { Fabricate(:team, updated_at: 1.week.ago, active: false) }
    let!(:inactive_team_two_weeks_ago) { Fabricate(:team, updated_at: 2.weeks.ago, active: false) }
    let!(:inactive_team_a_month_ago) { Fabricate(:team, updated_at: 1.month.ago, active: false) }
    it 'destroys teams inactive for two weeks' do
      expect do
        Team.purge!
      end.to change(Team, :count).by(-2)
      expect(Team.find(active_team.id)).to eq active_team
      expect(Team.find(inactive_team.id)).to eq inactive_team
      expect(Team.find(inactive_team_a_week_ago.id)).to eq inactive_team_a_week_ago
      expect(Team.find(inactive_team_two_weeks_ago.id)).to be nil
      expect(Team.find(inactive_team_a_month_ago.id)).to be nil
    end
  end
  context '#asleep?' do
    context 'default' do
      let(:team) { Fabricate(:team, created_at: Time.now.utc) }
      it 'false' do
        expect(team.asleep?).to be false
      end
    end
    context 'team created two weeks ago' do
      let(:team) { Fabricate(:team, created_at: 2.weeks.ago) }
      it 'is asleep' do
        expect(team.asleep?).to be true
      end
    end
    context 'team created two weeks ago and subscribed' do
      let(:team) { Fabricate(:team, created_at: 2.weeks.ago, subscribed: true) }
      before do
        allow(team).to receive(:inform_subscribed_changed!)
        team.update_attributes!(subscribed: true)
      end
      it 'is not asleep' do
        expect(team.asleep?).to be false
      end
    end
    context 'team created over two weeks ago' do
      let(:team) { Fabricate(:team, created_at: 2.weeks.ago - 1.day) }
      it 'is asleep' do
        expect(team.asleep?).to be true
      end
    end
    context 'team created over two weeks ago and subscribed' do
      let(:team) { Fabricate(:team, created_at: 2.weeks.ago - 1.day, subscribed: true) }
      it 'is not asleep' do
        expect(team.asleep?).to be false
      end
    end
  end
  context '#signup_to_mailing_list!' do
    let(:team) { Fabricate(:team, activated_user_id: 'activated_user_id') }
    let(:list) { double(Mailchimp::List, members: double(Mailchimp::List::Members)) }
    before do
      ENV['MAILCHIMP_LIST_ID'] = 'list-id'
      ENV['MAILCHIMP_API_KEY'] = 'api-key'

      expect(team.slack_client).to receive(:users_info).with(user: 'activated_user_id').and_return(
        user: {
          profile: {
            email: 'user@example.com',
            first_name: 'First',
            last_name: 'Last'
          }
        }
      )

      expect(team.send(:mailchimp_client)).to receive(:lists).with('list-id').and_return(list)
    end
    it 'subscribes the activating user' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return([])
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: {
          'FNAME' => 'First',
          'LNAME' => 'Last',
          'BOT' => 'Market'
        },
        status: 'pending',
        name: nil,
        tags: %w[marketbot trial],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      team.send(:signup_to_mailing_list!)
    end
    it 'merges tags' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return(
        [
          double(
            Mailchimp::List::Member,
            tags: [{ 'id' => 1513, 'name' => 'subscribed' }, { 'id' => 1525, 'name' => 'something' }],
            status: 'subscribed'
          )
        ]
      )
      expect(list.members).to receive(:create_or_update).with(
        email_address: 'user@example.com',
        merge_fields: {
          'FNAME' => 'First',
          'LNAME' => 'Last',
          'BOT' => 'Market'
        },
        status: 'subscribed',
        name: nil,
        tags: %w[something subscribed marketbot trial],
        unique_email_id: "#{team.team_id}-activated_user_id"
      )
      team.send(:signup_to_mailing_list!)
    end
    it 'does not attempt to create a new pending subscription' do
      expect(list.members).to receive(:where).with(email_address: 'user@example.com').and_return(
        [
          double(
            Mailchimp::List::Member,
            tags: [
              { 'id' => 1234, 'name' => 'trial' },
              { 'id' => 1513, 'name' => 'subscribed' },
              { 'id' => 1525, 'name' => 'marketbot' }
            ],
            status: 'pending'
          )
        ]
      )
      expect(list.members).to_not receive(:create_or_update)
      team.send(:signup_to_mailing_list!)
    end
    after do
      ENV.delete 'MAILCHIMP_API_KEY'
      ENV.delete 'MAILCHIMP_LIST_ID'
    end
  end
end
