module SlackMarket
  module Commands
    class Bought < SlackRubyBot::Commands::Base
      include SlackMarket::Commands::Mixins::Subscribe

      subscribe_command 'bought' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        expression = match['expression'] if match['expression']
        stocks = Market.qualify(expression.split, client.owner.dollars?) if expression
        quotes = Market.quotes(stocks) if stocks
        if quotes.any?
          quotes.each do |quote|
            logger.info "#{client.owner}, user=#{user} - BOUGHT #{quote.company_name} (#{quote.symbol}): $#{quote.latest_price}"
            if user.positions.where(symbol: quote.symbol, sold_at: nil).any?
              client.say channel: data.channel, text: "#{user.slack_mention} already holds #{quote.company_name} (#{quote.symbol})"
            else
              Position.create!(
                user: user,
                purchased_at: Time.now.utc,
                purchased_price_cents: quote.latest_price.to_f * 100,
                symbol: quote.symbol,
                name: quote.company_name
              )
              client.say channel: data.channel, text: "#{user.slack_mention} bought #{quote.company_name} (#{quote.symbol}) at ~$#{quote.latest_price}"
            end
          end
        end
      end
    end
  end
end
