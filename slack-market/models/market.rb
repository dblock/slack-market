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
    def quotes(stocks)
      Tickers.new(stocks)
    end

    # render the correct chart
    def render_chart(charts, slack_attachment, button, quote)
      # the actions array below contains formatted slack buttons
      actions = [
        {
          name: '1D',
          text: '1d',
          type: 'button',
          value: "#{quote.symbol}- 1d"
        },
        {
          name: '1M',
          text: '1m',
          type: 'button',
          value: "#{quote.symbol}- 1m"
        },
        {
          name: '1Y',
          text: '1y',
          type: 'button',
          value: "#{quote.symbol}- 1y"
        }
      ]

      chart_symbol = quote.symbol.tr('=', '-')
      if charts && !button
        slack_attachment[:image_url] = "https://www.google.com/finance/getchart?q=#{chart_symbol}&i=360"
        slack_attachment[:actions] = actions
        slack_attachment[:callback_id] = quote.name.to_s
      elsif charts && button
        slack_attachment[:image_url] = "https://www.google.com/finance/getchart?q=#{chart_symbol}&p=#{button}&i=360"
        slack_attachment[:actions] = actions
        slack_attachment[:callback_id] = quote.name.to_s
      end
    end

    # returns a stock formatted as a Slack message
    def to_slack_attachment(quote, opts = { charts: false, button: nil })
      attachment = {
        fallback: "#{quote.name} (#{quote.symbol}): $#{quote.last_trade_price}",
        title_link: "http://finance.google.com/q=#{quote.symbol}",
        title: "#{quote.name} (#{quote.symbol})",
        text: "$#{quote.last_trade_price} (#{quote.change_in_percent_s})",
        color: quote.change.to_f > 0 ? '#00FF00' : '#FF0000'
      }

      render_chart(opts[:charts], attachment, opts[:button], quote)

      attachment
    end
  end
end
