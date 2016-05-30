module SlackMarket
  module Commands
    class Positions < SlackRubyBot::Commands::Base
      command 'positions' do |client, data, match|
        expression = match['expression'] if match['expression']
        user = ::User.find_create_or_update_by_slack_id!(client, expression || data.user)
        message = user.positions.open.map(&:symbol).join(' ')
        message = "#{user.slack_mention} did not take any positions." if message.blank?
        client.say(channel: data.channel, text: message)
      end
    end
  end
end
