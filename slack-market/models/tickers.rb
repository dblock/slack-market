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

  def iex_client
    @iex_client ||= IEX::Api::Client.new
  end

  def get_tickers
    get_tickers_one_by_one
  end

  def get_tickers_one_by_one
    symbols.map do |symbol|
      begin
        iex_client.quote(symbol)
      rescue IEX::Errors::SymbolNotFoundError
        nil
      end
    end.compact
  end
end
