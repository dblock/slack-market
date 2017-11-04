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
    @tickers ||= values.map do |value|
      next unless symbols.map { |s| s.split('.').first }.include?(value[0])

      Ticker.new(
        symbol: value[0],
        name: value[1],
        last_trade_price: value[2].delete(',').to_f,
        change: value[3].delete(',').to_f,
        change_in_percent: value[5].delete(',').to_f
      )
    end.compact
  end

  private

  def data
    @data ||= begin
      url = "https://google.com/finance?q=#{symbols.join(';')}"
      open(url).read
    end
  end

  def rows
    @rows ||= begin
      related_data = data[/\"related\"\:(.*?)\]\}\]/]
      related_data = related_data[10..-1] + '}' if related_data
      related_data ? JSON.parse(related_data)['rows'] : []
    end
  end

  def values
    @values ||= begin
      if rows.any? || symbols.count <= 1
        rows.map { |row| row['values'] }
      else
        values = []
        symbols.each do |symbol|
          values.concat(Tickers.new([symbol]).send(:values))
        end
        values
      end
    end
  end
end
