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
    Array(StockQuote::Stock.quote(symbols.join(','))).map do |quote|
      Ticker.from_quote(quote)
    end.compact
  rescue JSON::ParserError
    symbols.count > 1 ? get_tickers_one_by_one : []
  end

  def get_tickers_one_by_one
    symbols.map do |symbol|
      begin
        Ticker.from_symbol(symbol)
      rescue JSON::ParserError
        nil
      end
    end.compact
  end
end
