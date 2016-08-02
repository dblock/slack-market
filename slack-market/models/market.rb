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
        quote.name = quote.name != 'N/A' ? quote.name : quote.symbol
        quote.last_trade_price != 'N/A'
      end
    end

    # render the correct chart
    def render_chart(charts, slack_attachment, button, quote)
      # the actions array below contains formatted slack buttons
      actions = [
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
        }]

      if charts && !button
        slack_attachment[:image_url] = "http://chart.finance.yahoo.com/z?s=#{quote.symbol}&z=l"
        slack_attachment[:actions] = actions
        slack_attachment[:callback_id] = "#{quote.name}"
      elsif charts && button
        slack_attachment[:image_url] = "http://chart.finance.yahoo.com/z?s=#{quote.symbol}&z=l&t=#{button}&z=l"
        slack_attachment[:actions] = actions
        slack_attachment[:callback_id] = "#{quote.name}"
      end
    end

    # returns a stock formatted as a Slack message
    def to_slack_attachment(quote, opts = { charts: false, button: nil })
      attachment = {
        fallback: "#{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}",
        title_link: "http://finance.yahoo.com/q?s=#{quote.symbol}",
        title: "#{quote.name} (#{quote.symbol})",
        text: "$#{quote.last_trade_price} (#{quote.change_in_percent})",
        color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000'
      }

      render_chart(opts[:charts], attachment, opts[:button], quote)

      attachment
    end
  end
end
