class WeatherKey
  # Round time to 20 minute slot and build namespaced key per city
  def self.key_for(city:, at:)
    rounded = Time.at((at.to_i / (20 * 60)) * 20 * 60)
    date = rounded.utc.strftime("%Y-%m-%d")
    time = rounded.utc.strftime("%H:%M")
    "weather/#{city}/#{date}/#{time}"
  end
end
