module SlackMarket
  module Commands
    class Positions < SlackRubyBot::Commands::Base
      include SlackMarket::Commands::Mixins::Subscribe

      subscribe_command 'positions' do |client, data, match|
        expression = match['expression'] if match['expression']
        user = ::User.find_by_slack_mention!(client.owner, expression) if expression
        user ||= ::User.find_create_or_update_by_slack_id!(client, data.user)
        positions = user.positions.open.asc(:_id)
        stocks = positions.map(&:symbol)
        if stocks.none?
          logger.info "#{client.owner}, user=#{user} - POSITIONS none"
          client.say(channel: data.channel, text: "#{user.slack_mention} does not have any open positions.")
        else
          quotes = Market.quotes(stocks)
          quotes = Hash[quotes.map { |quote| [quote.symbol, quote] }]
          message = positions.map do |position|
            quote = quotes[position.symbol]
            position.display(quote && quote.latest_price && quote.latest_price.to_f * 100)
          end.compact.join(', ')
          logger.info "#{client.owner}, user=#{user} - POSITIONS #{message}"
          client.say(channel: data.channel, text: message)
        end
      end
    end
  end
end
