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
    GoogleFinance::Quotes.search(symbols)
  rescue GoogleFinance::Errors::SymbolsNotFoundError
    symbols.count > 1 ? get_tickers_one_by_one : []
  end

  def get_tickers_one_by_one
    symbols.map do |symbol|
      begin
        GoogleFinance::Quote.get(symbol)
      rescue GoogleFinance::Errors::SymbolNotFoundError
        nil
      end
    end.compact
  end
end
