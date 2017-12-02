class Ticker
  include ActiveModel::Model

  attr_accessor :symbol
  attr_accessor :name
  attr_accessor :last_trade_price
  attr_accessor :change
  attr_accessor :change_in_percent

  def change_in_percent_s
    [
      change_in_percent > 0 ? '+' : '',
      format('%.2f', change_in_percent),
      '%'
    ].join
  end

  def self.from_symbol(symbol)
    from_quote StockQuote::Stock.quote(symbol)
  end

  def self.from_quote(quote)
    Ticker.new(
      symbol: quote.symbol,
      name: quote.name,
      last_trade_price: quote.l.to_f,
      change: quote.c.to_f,
      change_in_percent: quote.cp.to_f
    )
  end
end
