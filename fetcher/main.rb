# frozen_string_literal: true

require 'yaml'
require 'time'

require_relative 'lib/weather_fetcher'
require_relative 'lib/weather/provider_factory'
require_relative 'lib/storage/factory'
require_relative 'lib/weather/city_coordinates'
require_relative 'lib/weather/coordinates_resolver'

DEFAULT_CITIES = %w[
  Москва
  Санкт-Петербург
].freeze

def cities_from_file(path = File.join(__dir__, 'config', 'cities.yml'))
  return [] unless File.exist?(path)

  yaml = YAML.load_file(path)
  Array(yaml['cities']).map { |c| c.to_s.strip }.reject(&:empty?)
rescue StandardError
  []
end

def cities_from_env(value = ENV['CITIES'])
  return [] if value.nil? || value.strip.empty?

  value.split(',').map { |c| c.to_s.strip }.reject(&:empty?)
end

def load_cities
  from_file = cities_from_file
  return from_file unless from_file.empty?

  from_env = cities_from_env
  return from_env unless from_env.empty?

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
