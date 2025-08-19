class WeatherService
  SLOT_STEP_SECONDS = 20 * 60

  def initialize(storage: WeatherStorage.new, time_source: -> { Time.now })
    @storage = storage
    @time_source = time_source
  end

  def fetch_temperatures(cities)
    time_slots = build_time_slots
    begin
      cities.to_h do |city|
        temps = @storage.read_temperatures_batch(city: city, at_times: time_slots)
        readings = time_slots.zip(temps)
        trimmed = readings.drop_while { |_ts, temp| temp.nil? }
        trimmed = trimmed.empty? ? readings.last(1) : trimmed
        [ city, trimmed ]
      end
    ensure
      @storage.close
    end
  end

  def build_time_slots
    now = @time_source.call
    start_of_day = now.beginning_of_day
    slots = []
    t = start_of_day
    while t <= now
      slots << t
      t += SLOT_STEP_SECONDS
    end
    slots
  end
end
