class Market
  class << self
    # given an array of stocks, parse, mark as unique, remove $ signs, etc.
    def qualify(stocks, dollars = false)
      stocks = stocks.flatten
      stocks.select! { |s| s[0] == '$' } if dollars
      stocks.map! { |s| s.tr('$', '').upcase }
      stocks.uniq!
      stocks
    end

    # return stock quotes
    def quotes(stocks, fields = [:name, :symbol, :last_trade_price, :change, :change_in_percent])
      YahooFinance::Client.new.quotes(stocks, fields).select do |quote|
        quote.name != 'N/A'
      end
    end

    # returns a stock formatted as a Slack message
    # the actions property contains formatted slack buttons
    def to_slack_attachment(quote, charts = false, button = false)
      attachment = {
        fallback: "#{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}",
        title_link: "http://finance.yahoo.com/q?s=#{quote.symbol}",
        title: "#{quote.name} (#{quote.symbol})",
        text: "$#{quote.last_trade_price} (#{quote.change_in_percent})",
        color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000',
        callback_id: "#{quote.name}",
        actions: [
          {
            name: '1d',
            text: '1d',
            type: 'button',
            value: "#{quote.symbol}- 1d"
          },
          {
            name: '1m',
            text: '1m',
            type: 'button',
            value: "#{quote.symbol}- 1m"
          },
          {
            name: '1y',
            text: '1y',
            type: 'button',
            value: "#{quote.symbol}- 1y"
          }
        ]
      }
      if charts && !button
        attachment[:image_url] = "http://chart.finance.yahoo.com/z?s=#{quote.symbol}&z=l"
      elsif charts && button
        attachment[:image_url] = "http://chart.finance.yahoo.com/z?s=#{quote.symbol}&t=#{button}&z=l"
      end
      attachment
    end
  end
end
