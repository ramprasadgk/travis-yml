require 'faraday'

module Travis
  module Yml
    module RemoteVcs
      class Client
        private

        def connection
          @connection ||= Faraday.new(http_options.merge(url: config[:vcs][:url])) do |c|
            c.request :authorization, :token, config[:vcs][:token]
            c.request :retry, max: 5, interval: 0.1, backoff_factor: 2
            c.request :json
            c.use FaradayMiddleware::Instrumentation
            c.request :retry
            c.response :raise_error
            c.adapter :net_http
          end
        end

        def http_options
          { ssl: config[:ssl].to_h }
        end

        def request(method, name)
          resp = connection.send(method) { |req| yield(req) }
          JSON.parse(resp.body)['data']
        end

        def config
          Yml.config
        end
      end
    end
  end
end
