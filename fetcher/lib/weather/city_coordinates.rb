# frozen_string_literal: true

require_relative 'coordinates_resolver'

module Weather
  module CityCoordinates
    class << self
      def preload_cities(cities)
        Array(cities).each do |city|
          Weather::CoordinatesResolver.resolve(city)
        end
      end

      def get(city)
        Weather::CoordinatesResolver.resolve(city)
      end
    end
  end
end
