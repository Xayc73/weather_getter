# frozen_string_literal: true

require 'yaml'
require 'time'

require_relative 'lib/weather_fetcher'
require_relative 'lib/weather/provider_factory'
require_relative 'lib/storage/factory'
require_relative 'lib/weather/city_coordinates'
require_relative 'lib/weather/coordinates_resolver'

DEFAULT_CITIES = [
  'Москва',
  'Санкт-Петербург'
].freeze

def load_cities
  # 1) Try config file if present
  path = File.join(__dir__, 'config', 'cities.yml')
  if File.exist?(path)
    begin
      yaml = YAML.load_file(path)
      cfg_cities = Array(yaml['cities']).map { |c| c.to_s.strip }.reject(&:empty?)
      return cfg_cities unless cfg_cities.empty?
    rescue StandardError
      # ignore
    end
  end

  # 2) Fallback to ENV CITIES (comma-separated)
  env = ENV['CITIES']
  env_cities = if env && !env.strip.empty?
                  env.split(',').map(&:strip).reject(&:empty?)
                else
                  []
                end
  return env_cities unless env_cities.empty?

  # 3) Finally, built-in defaults
  DEFAULT_CITIES
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
