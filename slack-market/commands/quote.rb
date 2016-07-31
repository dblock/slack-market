module SlackMarket
  module Commands
    class Quote < SlackRubyBot::Commands::Base
      scan(/
        [\b\$]?[A-Z0-9]{1,}[\.\-\=][[[:upper:]]]+\b|
        \$[[[:alnum:]]]{1,}[\.\-\=][[[:alpha:]]]+|
        [\b\$]?[[[:upper:]]]{2,}\b|
        \$[[[:alpha:]]]{1,}|
        \b[[[:upper:]]]{1,}\$
      /x) do |client, data, stocks|
        stocks = Market.qualify(stocks, client.owner.dollars?)
        quotes = Market.quotes(stocks)
        next unless quotes.any?

        if Stripe.api_key && client.owner.subscription_expired?
          names = quotes.map { |quote| "#{quote.name} (#{quote.symbol})" }
          message = "Not showing quotes for #{names.or}. #{client.owner.subscribe_text}"
          client.say channel: data.channel, text: message
          logger.info "#{client.owner}, user=#{data.user}, text=#{data.text}, subscription expired"
        else
          message = {
            channel: data.channel,
            as_user: true,
            attachments: []
          }

          quotes.each do |quote|
            logger.info "#{client.owner}, user=#{data.user} - #{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}"
            message[:attachments] << Market.to_slack_attachment(quote, charts: client.owner.charts?)
          end

          client.web_client.chat_postMessage(message)
        end
      end
    end
  end
end
