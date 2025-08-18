# frozen_string_literal: true

require_relative '../clients/open_meteo_client'
require_relative '../city_coordinates'

module Weather
  module Providers
    class OpenMeteo
      def temperature_for(city)
        coords = Weather::CityCoordinates.get(city)
        data = Weather::Clients::OpenMeteoClient.current_weather(latitude: coords['latitude'],
                                                                 longitude: coords['longitude'])

        data.dig('current_weather', 'temperature')&.to_f
      end
    end
  end
end
