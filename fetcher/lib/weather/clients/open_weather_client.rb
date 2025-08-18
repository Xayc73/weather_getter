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
    class OpenWeatherClient
      include BaseClient
      include Singleton

      attr_reader :api_key

      BASE_URL = ENV.fetch('OPEN_WEATHER_API_URL', 'https://api.openweathermap.org').freeze

      class << self
        extend Forwardable
        def_delegators :instance, :current_weather, :configure
      end

      def initialize
        @api_key = nil
      end

      def configure(api_key:)
        @api_key = api_key
      end

      def current_weather(latitude:, longitude:)
        raise ArgumentError, 'OpenWeather api_key required' if api_key.nil? || api_key.strip.empty?

        params = { lat: latitude, lon: longitude, units: 'metric', appid: api_key }

        get('/data/2.5/weather', params)
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
