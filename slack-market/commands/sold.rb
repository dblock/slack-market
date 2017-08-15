module SlackMarket
  module Commands
    class Sold < SlackRubyBot::Commands::Base
      include SlackMarket::Commands::Mixins::Subscribe

      subscribe_command 'sold' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        expression = match['expression'] if match['expression']
        stocks = Market.qualify(expression.split, client.owner.dollars?) if expression
        quotes = Market.quotes(stocks) if stocks
        if quotes.any?
          quotes.each do |quote|
            logger.info "#{client.owner}, user=#{user} - SOLD #{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}"
            position = user.positions.where(symbol: quote.symbol, sold_at: nil).first
            if position
              display = position.display(quote.last_trade_price.to_f * 100)
              position.update_attributes!(sold_at: Time.now.utc, sold_price_cents: quote.last_trade_price.to_f * 100)
              client.say channel: data.channel, text: "#{user.slack_mention} sold #{quote.name} at ~$#{quote.last_trade_price}, #{display}"
            else
              client.say channel: data.channel, text: "#{user.slack_mention} does not hold #{quote.name} (#{quote.symbol})"
            end
          end
        end
      end
    end
  end
end
