# frozen_string_literal: true

module Weather
  module Clients
    module BaseClient
      class Error < StandardError; end

      private

      def get(endpoint, params = {})
        handle_request do
          connection.get(endpoint, params)
        end
      end

      def handle_request
        response = yield

        handle_response(response)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
        raise Error, "Network error: #{e.class}: #{e.message}"
      end

      def handle_response(response)
        raise Error, "HTTP #{response.status}: #{response.body}" unless response.success?

        response.body
      end
    end
  end
end
