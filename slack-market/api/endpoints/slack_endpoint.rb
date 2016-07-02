require 'pp'
module Api
  module Endpoints
    class GraphEndpoint < Grape::API
      format :json

      namespace :graph do
        desc 'Select graph.'

        params do
          requires :payload, type: String
        end

        post do
          p params.class
          # slack interactive messages send a payload.
          # the code below formats that object into a slack message
          # response to the channel
          payload = JSON.parse(params[:payload])
          button_name = payload['actions'][0]['name']
          button_value = payload['actions'][0]['value']
          stock_symbol = button_value.scan(/^[^\-]*/)
          channel = payload['channel']['id']
          token = payload['token']
          ts = payload['original_message']['ts']
          chart = true
          quotes = Market.quotes([stock_symbol])

          slack_attachment = Market.to_slack_attachment(quotes[0], charts: chart, button: button_name)
          # verifying message token
          if token == ENV['SLACK_VERIFICATION_TOKEN']
            # formatted Slack message response
            {
              as_user: true,
              channel: channel,
              ts: ts,
              token: token,
              text: "Below is the #{button_name} chart",
              attachments: [slack_attachment]
            }
          else
            error! 'Message token is not coming from Slack.', 401 unless token == ENV['SLACK_VERIFICATION_TOKEN']
          end
        end
      end
    end
  end
end
