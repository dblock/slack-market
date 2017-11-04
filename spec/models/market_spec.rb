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
end
