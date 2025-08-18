# frozen_string_literal: true

require_relative '../clients/open_weather_client'
require_relative '../city_coordinates'

module Weather
  module Providers
    class OpenWeather
      def temperature_for(city)
        coords = Weather::CityCoordinates.get(city)
        data = Weather::Clients::OpenWeatherClient.current_weather(latitude: coords['latitude'],
                                                                   longitude: coords['longitude'])

        data.dig('main', 'temp')&.to_f
      end
    end
  end
end
