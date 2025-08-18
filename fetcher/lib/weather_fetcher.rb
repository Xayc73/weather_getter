# frozen_string_literal: true

require 'json'
require 'time'
require 'rufus-scheduler'
require_relative 'weather/coordinates_resolver'
require_relative 'weather/city_coordinates'

class WeatherFetcher
  def initialize(cities:, provider:, storage:)
    @cities = cities
    @provider = provider
    @storage = storage

    Weather::CoordinatesResolver.configure(storage: @storage)
    Weather::CityCoordinates.preload_cities(@cities)
  end

  def run
    scheduler = Rufus::Scheduler.new
    now = Time.now
    delay_seconds = seconds_until_next_boundary(now)
    scheduler.in "#{delay_seconds}s" do
      fetch_and_store
      scheduler.every '20m' do
        fetch_and_store
      end
    end
    scheduler.join
  end

  def fetch_and_store
    @cities.each do |city|
      now = Time.now
      temp = @provider.temperature_for(city)
      key = key_for(city: city, at: now)
      value = { city: city, at: now.utc.iso8601, temp: temp }.to_json
      @storage.put(key: key, value: value)
      puts "Stored #{city} #{temp}C at #{now}"
    rescue StandardError => e
      warn "Fetch error for #{city}: #{e.class} #{e.message}"
      next
    end
  end

  def close
    @storage.close if @storage.respond_to?(:close)
  end

  private

  def key_for(city:, at:)
    rounded = Time.at((at.to_i / (20 * 60)) * 20 * 60)
    date = rounded.utc.strftime('%Y-%m-%d')
    time = rounded.utc.strftime('%H:%M')
    "weather/#{city}/#{date}/#{time}"
  end

  def seconds_until_next_boundary(now)
    slot = (now.to_i / (20 * 60)) * 20 * 60
    next_slot = slot + 20 * 60
    [next_slot - now.to_i, 0].max
  end
end
