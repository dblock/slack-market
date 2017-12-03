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

          interval = period == '1d' ? 360 : 86_400

          url = "https://finance.google.com/finance/getprices?i=#{interval}&p=#{period}&f=d,c&df=cpct&auto=0&q=#{params[:q]}"

          RestClient::Request.execute(url: url, method: :get, verify_ssl: false) do |response|
            csv = CSV.new(response.body.split[8..-1].join("\n"))
            data = csv.to_a.map do |row|
              next unless row.count == 2
              row[1].to_f
            end.compact

            g = Gruff::Line.new
            g.data params[:q], data
            content_type 'image/png'
            g.to_blob
          end
        end
      end
    end
  end
end
