class WeatherController < ApplicationController
  def index
    @cities = ENV.fetch('DEFAULT_CITIES', 'Москва,Санкт-Петербург').split(',').map(&:strip)
    @time_slots = build_time_slots
    @temperatures_by_city = fetch_temperatures(@cities, @time_slots)
  end

  private

  def build_time_slots
    now = Time.now
    start_of_day = now.beginning_of_day
    slots = []
    t = start_of_day
    while t <= now
      slots << t
      t += 20.minutes
    end
    slots
  end

  def fetch_temperatures(cities, time_slots)
    nats_url = ENV.fetch('NATS_URL', 'nats://localhost:4222')
    client = NatsClient.new(nats_url)
    begin
      cities.to_h do |city|
        readings = time_slots.map do |ts|
          key = WeatherKey.key_for(city: city, at: ts)
          value = client.read_kv(bucket: 'weather', key: key)
          [ts, value && JSON.parse(value)['temp']]
        end
        # drop leading nils until first actual reading appears
        trimmed = readings.drop_while { |_ts, temp| temp.nil? }
        trimmed = trimmed.empty? ? readings.last(1) : trimmed
        [city, trimmed]
      end
    ensure
      client.close
    end
  end
end
