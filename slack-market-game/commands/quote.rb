module SlackMarketGame
  module Commands
    class Quote < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        tickers = match['expression'].split.reject(&:blank?).map(&:upcase) if match.names.include?('expression')
        logger.info "QUOTE: #{client.team}, user=#{data.user} - #{tickers.join(', ')}"
        quotes = YahooFinance::Client.new.quotes(tickers, [:name, :symbol, :last_trade_price, :change, :change_in_percent])
        quotes.each do |quote|
          last_trade_price_s = Money.new(quote.last_trade_price.to_f * 100, 'USD').format
          client.web_client.chat_postMessage(
            channel: data.channel,
            as_user: true,
            attachments: [
              {
                fallback: "#{quote.name} (#{quote.symbol}): #{last_trade_price_s}",
                title: "#{quote.name} (#{quote.symbol})",
                text: "#{last_trade_price_s} (#{quote.change_in_percent})",
                color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000'
              }
            ]
          )
        end
      end
    end
  end
end
