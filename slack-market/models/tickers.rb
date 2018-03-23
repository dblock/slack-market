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
    get_tickers_one_by_one
  end

  def get_tickers_one_by_one
    symbols.map do |symbol|
      begin
        IEX::Quote.get(symbol)
      rescue IEX::Errors::SymbolNotFoundError
        nil
      end
    end.compact
  end
end
