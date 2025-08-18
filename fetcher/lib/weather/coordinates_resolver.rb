# frozen_string_literal: true

require 'json'
require 'time'
require 'uri'
require 'singleton'

require_relative 'clients/open_meteo_geocoding_client'

module Weather
  class CoordinatesResolver
    include Singleton

    def self.configure(storage:)
      instance.storage = storage
    end

    def self.resolve(city)
      instance.resolve(city)
    end

    attr_writer :storage

    def resolve(city)
      raise 'CoordinatesResolver is not configured with storage' unless @storage

      key = key_for(city)
      cached = fetch_cached_coordinates(key)
      return cached if cached

      geocoded = geocode_city(city)
      return nil unless geocoded

      persist_coordinates(key, geocoded)
      geocoded
    end

    private

    def parse_payload(payload)
      return payload if payload.is_a?(Hash)

      JSON.parse(payload)
    rescue JSON::ParserError, TypeError
      nil
    end

    def fetch_cached_coordinates(key)
      payload = @storage.get(key: key)
      return nil unless payload

      parse_payload(payload)
    end

    def persist_coordinates(key, data)
      value = {
        'latitude' => data[:latitude],
        'longitude' => data[:longitude],
        'updated_at' => Time.now.utc.iso8601
      }.to_json
      @storage.put(key: key, value: value)
    end

    def geocode_city(city)
      data = Weather::Clients::OpenMeteoGeocodingClient.geocode_city(city, count: 3, lang: 'ru')
      results = data['results'] || []
      return nil if results.empty?

      preferred = results.first
      { latitude: preferred['latitude'], longitude: preferred['longitude'] }
    rescue StandardError => e
      warn "Geocoding failed for #{city}: #{e.class} #{e.message}"
      nil
    end

    def key_for(city)
      encoded = URI.encode_www_form_component(city.to_s.strip)
      "geocode/#{encoded}"
    end
  end
end
