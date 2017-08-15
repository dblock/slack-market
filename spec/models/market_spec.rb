require 'spec_helper'

describe Market do
  describe '#qualify' do
    it 'empty array' do
      expect(Market.qualify([])).to eq []
    end
    it 'flattens array' do
      expect(Market.qualify([[]])).to eq []
    end
    it 'produces unique results' do
      expect(Market.qualify(%w[MSFT MSFT])).to eq ['MSFT']
      expect(Market.qualify(['MSFT', '$MSFT'])).to eq ['MSFT']
    end
    it 'supports dollar option' do
      expect(Market.qualify(['ABCD', '$MSFT'], false)).to eq %w[ABCD MSFT]
      expect(Market.qualify(['ABCD', '$MSFT'], true)).to eq ['MSFT']
    end
    it 'upcases' do
      expect(Market.qualify(%w[MSFT msft])).to eq ['MSFT']
    end
  end
  describe '#quotes' do
    it 'filters out N/A responses' do
      allow_any_instance_of(YahooFinance::Client).to receive(:quotes).and_return([
                                                                                   Hashie::Mash.new(name: 'N/A', last_trade_price: 'N/A'),
                                                                                   Hashie::Mash.new(name: 'MSFT', last_trade_price: '56.58')
                                                                                 ])
      quotes = Market.quotes(%w[FOO MSFT])
      expect(quotes.size).to eq 1
      expect(quotes[0].name).to eq 'MSFT'
    end
    it 'uses the symbol for the name if the name is N/A' do
      allow_any_instance_of(YahooFinance::Client).to receive(:quotes).and_return([
                                                                                   Hashie::Mash.new(
                                                                                     name: 'N/A',
                                                                                     symbol: '300024.SZ',
                                                                                     last_trade_price: '23.71',
                                                                                     change: '+0.10',
                                                                                     change_in_percent: '+0.42%'
                                                                                   )
                                                                                 ])
      quotes = Market.quotes(%w[300024.SZ])
      expect(quotes[0].name).to eq '300024.SZ'
    end
  end
end
