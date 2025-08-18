# frozen_string_literal: true

require 'yaml'
require 'time'

require_relative 'lib/weather_fetcher'
require_relative 'lib/weather/provider_factory'
require_relative 'lib/storage/factory'
require_relative 'lib/weather/city_coordinates'
require_relative 'lib/weather/coordinates_resolver'

def load_cities
  path = File.join(__dir__, 'config', 'cities.yml')
  yaml = YAML.load_file(path)
  yaml['default_cities'] || []
end

def load_fetcher_config
  path = File.join(__dir__, 'config', 'fetcher.yml')
  File.exist?(path) ? YAML.load_file(path) : {}
end

def preload_cities_coordinates(cities)
  Array(cities).each do |city|
    Weather::CoordinatesResolver.resolve(city)
  end
end

if __FILE__ == $PROGRAM_NAME
  cities = load_cities
  # preload_cities_coordinates(cities)
  config = load_fetcher_config

  storage = Storage::Factory.build(config)

  provider = Weather::ProviderFactory.build(config)

  fetcher = WeatherFetcher.new(cities: cities, provider: provider, storage: storage)

  at_exit do
    fetcher.close
  end

  trap('TERM') do
    exit
  end
  trap('INT') do
    exit
  end

  fetcher.run
end
