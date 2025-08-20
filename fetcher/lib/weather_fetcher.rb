# frozen_string_literal: true

require 'json'
require 'time'
require 'rufus-scheduler'
require_relative 'weather/coordinates_resolver'
require_relative 'weather/city_coordinates'

class WeatherFetcher
  TIME_SLOT_SECONDS = ENV.fetch('TIME_SLOT_SECONDS', 20 * 60).to_i

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
      scheduler.every "#{TIME_SLOT_SECONDS}s" do
        fetch_and_store
      end
    end
    scheduler.join
  end

  def fetch_and_store
    now = Time.now
    date, time_slot = build_time_parts(now)

    @cities.each do |city|
      fetch_and_store_city(city: city, date: date, time_slot: time_slot, now: now)
    rescue StandardError => e
      warn "Fetch error for #{city}: #{e.class} #{e.message}"
      next
    end
  end

  def close
    @storage.close if @storage.respond_to?(:close)
  end

  private

  def build_time_parts(now)
    rounded = Time.at((now.to_i / TIME_SLOT_SECONDS) * TIME_SLOT_SECONDS)
    [rounded.utc.strftime('%Y-%m-%d'), rounded.utc.strftime('%H:%M')]
  end

  def fetch_and_store_city(city:, date:, time_slot:, now:)
    temp = @provider.temperature_for(city)
    day_key = day_key_for(city: city, date: date)
    day_map = read_day_map(day_key)
    day_map[time_slot] = temp
    write_day_map(day_key, day_map)
    puts "Stored #{city} #{temp}C at #{now}"
  end

  def day_key_for(city:, date:)
    "weather/#{city}/#{date}"
  end

  def read_day_map(day_key)
    existing = @storage.get(key: day_key)
    parsed = existing ? safe_parse_json(existing) : {}
    parsed.is_a?(Hash) ? parsed : {}
  rescue StandardError
    {}
  end

  def write_day_map(day_key, map)
    @storage.put(key: day_key, value: JSON.dump(map))
  end

  def safe_parse_json(json)
    JSON.parse(json)
  rescue StandardError
    nil
  end

  def seconds_until_next_boundary(now)
    slot = (now.to_i / TIME_SLOT_SECONDS) * TIME_SLOT_SECONDS
    next_slot = slot + TIME_SLOT_SECONDS
    [next_slot - now.to_i, 0].max
  end
end
