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
    r = related_tickers
    return r if r && r.any?
    m = meta_ticker
    return [m] if m
    []
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

  def meta_ticker
    @meta_ticker ||= begin
      title = data[/\<div class=\"g-unit g-first\"\>\<h3\>(.*?)\<\/div\>/m]
      title = Nokogiri::XML(title) if title
      sharebox_data = data[/\<div id=\"sharebox-data\"(.*?)\<\/div\>/m]
      sharebox_data = Nokogiri::XML(sharebox_data) if sharebox_data
      if title && sharebox_data
        Ticker.new(
          name: title.xpath('//h3').text,
          symbol: sharebox_data.xpath('//meta[@itemprop="name"]').first['content'],
          last_trade_price: sharebox_data.xpath('//meta[@itemprop="price"]').first['content'].delete(',').to_f,
          change: sharebox_data.xpath('//meta[@itemprop="priceChange"]').first['content'].delete(',').to_f,
          change_in_percent: sharebox_data.xpath('//meta[@itemprop="priceChangePercent"]').first['content'].delete(',').to_f
        )
      end
    end
  end

  def related_tickers
    @related_tickers ||= related_values.map do |value|
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

  def related_values
    @related_values ||= begin
      if rows.any? || symbols.count <= 1
        rows.map { |row| row['values'] }
      else
        values = []
        symbols.each do |symbol|
          values.concat(Tickers.new([symbol]).send(:related_values))
        end
        values
      end
    end
  end
end
