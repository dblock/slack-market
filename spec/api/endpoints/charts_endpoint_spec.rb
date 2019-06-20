require 'spec_helper'

describe Api::Endpoints::ChartsEndpoint do
  include Api::Test::EndpointTest

  context 'chart' do
    it 'shows a daily chart', vcr: { cassette_name: 'iex/msft_chart' } do
      get '/api/charts/MSFT.png'
      expect(last_response.status).to eq 200
      expect(last_response.headers['Content-Type']).to eq 'image/png'
    end
  end
end
