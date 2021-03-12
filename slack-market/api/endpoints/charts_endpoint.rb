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
          optional :p, type: String, default: '1d'
        end
        get ':q' do
          error!('Currently Disabled', 400) unless params[:p] == '1d'

          expire_in = case params[:p]
                      when '1d' then 60 * 60
                      else 60 * 60 * 12
                      end

          header 'Expires', CGI.rfc1123_date(Time.now.utc + expire_in)
          key = "api:charts:#{params[:q]}}:#{params[:p]}"

          Cachy.cache(key, expires_in: expire_in) do
            client = IEX::Api::Client.new
            chart = client.chart(params[:q], params[:p])
            data = chart.map(&:high).select { |v| v && v >= 0 }
            g = Gruff::Line.new
            g.data params[:q], data
            content_type 'image/png'
            g.to_image.to_blob do
              self.format = 'PNG'
            end
          end
        end
      end
    end
  end
end
