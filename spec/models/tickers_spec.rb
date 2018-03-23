require 'spec_helper'

describe Tickers do
  context 'one ticker', vcr: { cassette_name: 'msft' } do
    let(:tickers) { Tickers.new(['MSFT']) }
    let(:ticker) { tickers.first }
    it 'retrieves the MSFT ticker' do
      expect(tickers.count).to eq 1
      expect(ticker.symbol).to eq 'MSFT'
      expect(ticker.company_name).to eq 'Microsoft Corporation'
      expect(ticker.latest_price).to eq 89.24
      expect(ticker.change).to eq -0.545
      expect(ticker.change_percent).to eq -0.00607
    end
  end
  context 'multiple tickers', vcr: { cassette_name: 'msft_goog' } do
    let(:tickers) { Tickers.new(%w[MSFT GOOG]) }
    it 'retrieves two tickers' do
      expect(tickers.count).to eq 2
      expect(tickers.map(&:symbol)).to eq %w[MSFT GOOG]
    end
  end
  context 'with an invalid ticker', vcr: { cassette_name: 'invalid' } do
    let(:tickers) { Tickers.new(['INVALID']) }
    it 'retrieves no tickers' do
      expect(tickers.count).to eq 0
    end
  end
  context 'currency', vcr: { cassette_name: 'btc' } do
    let(:tickers) { Tickers.new(%w[BTC]) }
    pending 'retrieves BTC ticker' do
      expect(tickers.count).to eq 1
      expect(tickers.map(&:symbol)).to eq %w[BTCUSD]
    end
  end
end
