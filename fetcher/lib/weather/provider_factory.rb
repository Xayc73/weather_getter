# frozen_string_literal: true

require_relative 'providers/open_meteo'
require_relative 'providers/open_weather'

module Weather
  class ProviderFactory
    def self.build(config = {})
      selected = (config['provider'] || ENV['WEATHER_PROVIDER'] || 'open_meteo').to_s

      case selected
      when 'open_meteo'
        Weather::Providers::OpenMeteo.new
      when 'open_weather'
        api_key = config.dig('providers', 'open_weather', 'api_key') || ENV['OPENWEATHER_API_KEY']
        Weather::Clients::OpenWeatherClient.configure(api_key: api_key)
        Weather::Providers::OpenWeather.new
      else
        raise ArgumentError, "Unknown provider: #{selected}"
      end
    end
  end
end
