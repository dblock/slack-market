module Api
  module Endpoints
    class TeamsEndpoint < Grape::API
      format :json
      helpers Api::Helpers::CursorHelpers
      helpers Api::Helpers::SortHelpers
      helpers Api::Helpers::PaginationParameters

      namespace :teams do
        desc 'Get a team.'
        params do
          requires :id, type: String, desc: 'Team ID.'
        end
        get ':id' do
          team = Team.where(_id: params[:id], api: true).first || error!('Not Found', 404)
          present team, with: Api::Presenters::TeamPresenter
        end

        desc 'Get all the teams.'
        params do
          optional :active, type: Boolean, desc: 'Return active teams only.'
          use :pagination
        end
        sort Team::SORT_ORDERS
        get do
          teams = Team.api
          teams = teams.active if params[:active]
          teams = paginate_and_sort_by_cursor(teams, default_sort_order: '-_id')
          present teams, with: Api::Presenters::TeamsPresenter
        end

        desc 'Create a team using an OAuth token.'
        params do
          requires :code, type: String
        end
        post do
          client = Slack::Web::Client.new

          raise 'Missing SLACK_CLIENT_ID or SLACK_CLIENT_SECRET.' unless ENV.key?('SLACK_CLIENT_ID') && ENV.key?('SLACK_CLIENT_SECRET')

          rc = client.oauth_access(
            client_id: ENV['SLACK_CLIENT_ID'],
            client_secret: ENV['SLACK_CLIENT_SECRET'],
            code: params[:code]
          )

          access_token = rc['access_token']
          team = Team.where(access_token: access_token).first

          token = rc['bot']['bot_access_token']
          team ||= Team.where(token: token).first

          team_id = rc['team_id']
          team ||= Team.where(team_id: team_id).first

          bot_user_id = rc['bot']['bot_user_id']
          user_id = rc['user_id']

          if team && !team.active?
            team.update_attributes!(
              created_at: Time.now.utc,
              activated_user_id: user_id,
              bot_user_id: bot_user_id,
              active: true,
              token: token,
              access_token: access_token
            )
          elsif team
            raise "Team #{team.name} is already registered."
          else
            team = Team.create!(
              token: token,
              team_id: rc['team_id'],
              name: rc['team_name'],
              activated_user_id: user_id,
              bot_user_id: bot_user_id
            )
          end

          SlackMarket::Service.instance.start!(team)
          present team, with: Api::Presenters::TeamPresenter
        end
      end
    end
  end
end
