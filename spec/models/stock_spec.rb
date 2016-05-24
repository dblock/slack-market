require 'spec_helper'

describe Stock do
  describe '#qualify' do
    it 'empty array' do
      expect(Stock.qualify([])).to eq []
    end
    it 'flattens array' do
      expect(Stock.qualify([[]])).to eq []
    end
    it 'produces unique results' do
      expect(Stock.qualify(%w(MSFT MSFT))).to eq ['MSFT']
      expect(Stock.qualify(['MSFT', '$MSFT'])).to eq ['MSFT']
    end
    it 'supports dollar option' do
      expect(Stock.qualify(['ABCD', '$MSFT'], false)).to eq %w(ABCD MSFT)
      expect(Stock.qualify(['ABCD', '$MSFT'], true)).to eq ['MSFT']
    end
  end
  describe '#quotes' do
    it 'filters out N/A responses' do
      allow_any_instance_of(YahooFinance::Client).to receive(:quotes).and_return([
        Hashie::Mash.new(name: 'N/A'),
        Hashie::Mash.new(name: 'MSFT')
      ])
      quotes = Stock.quotes(%w(FOO MSFT))
      expect(quotes.size).to eq 1
      expect(quotes[0].name).to eq 'MSFT'
    end
  end
end
