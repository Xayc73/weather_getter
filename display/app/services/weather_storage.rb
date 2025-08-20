class WeatherStorage
  def initialize(client: nil, nats_url: ENV.fetch("NATS_URL", "nats://nats:4222"))
    @client = client || NatsClient.new(nats_url)
  end

  def read_temperatures_batch(city:, at_times:)
    grouped = at_times.group_by { |t| WeatherKey.key_for(city: city, at: t) }

    day_data_cache = {}
    grouped.keys.each do |day_key|
      raw = @client.read_kv(bucket: "weather", key: day_key)
      day_data_cache[day_key] = (JSON.parse(raw) rescue nil)
    end

    at_times.map do |t|
      day_key = WeatherKey.key_for(city: city, at: t)
      slot = WeatherKey.time_slot_for(at: t)
      day = day_data_cache[day_key]
      next nil unless day.is_a?(Hash)

      value = day[slot]
      value.is_a?(Hash) ? value["temp"] : value
    end
  end

  def close
    @client.close
  end
end
