class WeatherKey
  TIME_SLOT_SECONDS = ENV.fetch("TIME_SLOT_SECONDS", 20 * 60).to_i

  # Build day-level key per city. Values are time-slot -> data for that day.
  def self.key_for(city:, at:)
    rounded = round_to_slot(at)
    date = rounded.utc.strftime("%Y-%m-%d")
    "weather/#{city}/#{date}"
  end

  def self.time_slot_for(at:)
    round_to_slot(at).utc.strftime("%H:%M")
  end

  def self.round_to_slot(at)
    Time.at((at.to_i / TIME_SLOT_SECONDS) * TIME_SLOT_SECONDS)
  end
  private_class_method :round_to_slot
end
