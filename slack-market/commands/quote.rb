module SlackMarket
  module Commands
    class Quote < SlackRubyBot::Commands::Base
      scan(/[\b\$]?[A-Z]{1,}\.[A-Z]+\b|[\b\$]?[A-Z]{2,}\b|\$[A-Z]{1,}\b|\b[A-Z]{1,}\$/) do |client, data, stocks|
        stocks = stocks.flatten

        stocks.select! { |s| s[0] == '$' } if client.owner.dollars?
        stocks.map! { |s| s.tr('$', '') }
        stocks.uniq!

        quotes = YahooFinance::Client.new.quotes(stocks, [:name, :symbol, :last_trade_price, :change, :change_in_percent]).select do |quote|
          quote.name != 'N/A'
        end

        next unless quotes.any?

        message = {
          channel: data.channel,
          as_user: true,
          attachments: []
        }

        quotes.each do |quote|
          logger.info "#{client.owner}, user=#{data.user} - #{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}"
          attachment = {
            fallback: "#{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}",
            title_link: "http://finance.yahoo.com/q?s=#{quote.symbol}",
            title: "#{quote.name} (#{quote.symbol})",
            text: "$#{quote.last_trade_price} (#{quote.change_in_percent})",
            color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000'
          }
          attachment[:image_url] = "http://chart.finance.yahoo.com/z?s=#{quote.symbol}&z=l" if client.owner.charts?
          message[:attachments] << attachment
        end

        client.web_client.chat_postMessage(message)
      end
    end
  end
end
