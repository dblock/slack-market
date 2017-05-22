module SlackMarket
  module Commands
    class Sucks < SlackRubyBot::Commands::Base
      match(/market sucks/) do |client, data, _match|
        logger.info "#{client.owner}, user=#{data.user} - market sucks!"

        # DIA (Dow Jones Industrial Average ETF) closely but not quite imiates the DOW
        quotes = YahooFinance::Client.new.quotes(['DIA'], [:name, :symbol, :last_trade_price, :change, :change_in_percent]).select do |quote|
          quote.name != 'N/A'
        end

        quote = quotes.first

        client.web_client.chat_postMessage(
          channel: data.channel,
          as_user: true,
          text: quote.change.to_f > 0 ? "No <@#{data.user}>, market is up, you suck!" : "Indeed <@#{data.user}>, market sucks!",
          attachments: [{
            title_link: 'http://finance.yahoo.com/q?s=%5EDJI',
            title: 'Dow Jones Industrial Average (^DJI)',
            color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000',
            image_url: 'https://www.google.com/finance/getchart?q=DJI'
          }]) if quote
      end
    end
  end
end
