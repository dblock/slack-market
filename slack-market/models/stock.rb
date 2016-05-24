class Stock
  class << self
    # given an array of stocks, parse, mark as unique, remove $ signs, etc.
    def qualify(stocks, dollars = false)
      stocks = stocks.flatten
      stocks.select! { |s| s[0] == '$' } if dollars
      stocks.map! { |s| s.tr('$', '') }
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
    def to_slack_attachment(quote, charts = false)
      attachment = {
        fallback: "#{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}",
        title_link: "http://finance.yahoo.com/q?s=#{quote.symbol}",
        title: "#{quote.name} (#{quote.symbol})",
        text: "$#{quote.last_trade_price} (#{quote.change_in_percent})",
        color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000'
      }
      attachment[:image_url] = "http://chart.finance.yahoo.com/z?s=#{quote.symbol}&z=l" if charts
      attachment
    end
  end
end
