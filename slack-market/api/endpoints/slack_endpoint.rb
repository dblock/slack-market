require 'pp'
module Api
  module Endpoints
    class SlackEndpoint < Grape::API
      format :json

      namespace :graph do
        desc 'Select graph.'
        post do
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

          quotes = Market.quotes([stock_symbol])

          charts = true

          slack_attachment = Market.to_slack_attachment(quotes[0], charts, button_name)
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
            fail 'Message token is not actually coming from Slack.'
          end
        end
      end
    end
  end
end
