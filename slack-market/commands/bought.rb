module SlackMarket
  module Commands
    class Bought < SlackRubyBot::Commands::Base
      command 'bought' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        expression = match['expression'] if match['expression']
        stocks = Market.qualify(expression.split, client.owner.dollars?) if expression
        quotes = Market.quotes(stocks) if stocks
        quotes.each do |quote|
          logger.info "#{client.owner}, user=#{user} - BOUGHT #{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}"
          if user.positions.where(symbol: quote.symbol, sold_at: nil).any?
            client.say channel: data.channel, text: "#{user.slack_mention} already holds #{quote.name} (#{quote.symbol})"
          else
            Position.create!(
              user: user,
              purchased_at: Time.now.utc,
              purchased_price_cents: quote.last_trade_price.to_f * 100,
              symbol: quote.symbol
            )
            client.say channel: data.channel, text: "#{user.slack_mention} bought #{quote.name} (#{quote.symbol}) at ~$#{quote.last_trade_price}"
          end
        end if quotes.any?
      end
    end
  end
end
