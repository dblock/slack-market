require 'csv'

module Api
  module Endpoints
    class ChartsEndpoint < Grape::API
      content_type :png, 'image/png'
      format :png

      namespace :charts do
        desc 'Get chart.'
        params do
          requires :q, type: String
          optional :i, type: Integer, default: 360
          optional :p, type: String, default: '1d'
        end
        get ':q' do
          period = case params[:p]
                   when '1m', '1M' then '30d'
                   when '1y', '1Y' then '1Y'
                   else '1d'
          end

          chart = IEX::Resources::Chart.get(params[:q], period)
          data = chart.map(&:high)
          g = Gruff::Line.new
          g.data params[:q], data
          content_type 'image/png'
          g.to_blob
        end
      end
    end
  end
end
