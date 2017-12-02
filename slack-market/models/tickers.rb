require 'open-uri'

class Tickers
  include Enumerable

  attr_reader :symbols

  def initialize(symbols)
    @symbols = symbols
  end

  def each(&block)
    tickers.each(&block)
  end

  def tickers
    @tickers ||= get_tickers
  end

  private

  def get_tickers
    Array(StockQuote::Stock.quote(symbols.join(','))).map do |s|
      Ticker.new(
        symbol: s.symbol,
        name: s.name,
        last_trade_price: s.l.to_f,
        change: s.c.to_f,
        change_in_percent: s.cp.to_f
      )
    end.compact
  rescue JSON::ParserError
    symbols.count > 1 ? get_tickers_one_by_one : []
  end

  def get_tickers_one_by_one
    symbols.map do |symbol|
      begin
        s = StockQuote::Stock.quote(symbol)
        Ticker.new(
          symbol: s.symbol,
          name: s.name,
          last_trade_price: s.l.to_f,
          change: s.c.to_f,
          change_in_percent: s.cp.to_f
        )
      rescue JSON::ParserError
        nil
      end
    end.compact
  end
end
