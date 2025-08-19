class WeatherStorage
  def initialize(client: nil, nats_url: ENV.fetch("NATS_URL", "nats://nats:4222"))
    @client = client || NatsClient.new(nats_url)
  end

  def read_temperature(city:, at:)
    key = WeatherKey.key_for(city: city, at: at)

    value = @client.read_kv(bucket: "weather", key: key)
    value && JSON.parse(value)["temp"]
  end

  def read_temperatures_batch(city:, at_times:)
    keys = at_times.map { |t| WeatherKey.key_for(city: city, at: t) }
    keys.map do |key|
      value = @client.read_kv(bucket: "weather", key: key)
      value && JSON.parse(value)["temp"]
    end
  end

  def close
    @client.close
  end
end
