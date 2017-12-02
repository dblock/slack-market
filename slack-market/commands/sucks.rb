module SlackMarket
  module Commands
    class Sucks < SlackRubyBot::Commands::Base
      match(/market sucks/) do |client, data, _match|
        logger.info "#{client.owner}, user=#{data.user} - market sucks!"

        # DIA (Dow Jones Industrial Average ETF) closely but not quite imiates the DOW
        quotes = Tickers.new(['DIA'])
        quote = quotes.first

        if quote
          client.web_client.chat_postMessage(
            channel: data.channel,
            as_user: true,
            text: quote.change.to_f > 0 ? "No <@#{data.user}>, market is up, you suck!" : "Indeed <@#{data.user}>, market sucks!",
            attachments: [{
              title_link: 'http://finance.google.com/q=%5EDJI',
              title: 'Dow Jones Industrial Average (^DJI)',
              color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000',
              image_url: '/api/charts/DJI'
            }]
          )
        end
      end
    end
  end
end
