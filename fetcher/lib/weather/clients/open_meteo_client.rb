# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'faraday/typhoeus'
require 'oj'
require 'forwardable'
require 'singleton'
require_relative 'concerns/base_client'

module Weather
  module Clients
    class OpenMeteoClient
      include BaseClient
      include Singleton

      BASE_URL = ENV.fetch('OPEN_METEO_API_URL', 'https://api.open-meteo.com').freeze

      class << self
        extend Forwardable
        def_delegators :instance, :current_weather
      end

      def current_weather(latitude:, longitude:)
        params = { latitude: latitude, longitude: longitude, current_weather: true, timezone: 'UTC' }

        get('/v1/forecast', params)
      end

      private

      def connection
        @connection ||= Faraday.new(
          url: BASE_URL,
          request: { open_timeout: 2, timeout: 5, read_timeout: 5 }
        ) do |f|
          f.response :json, content_type: /\bjson$/, parser_options: { decoder: [Oj, :load] }
          f.request  :retry, max: 2, interval: 0.1, backoff_factor: 2
          f.adapter  :typhoeus
        end
      end
    end
  end
end
