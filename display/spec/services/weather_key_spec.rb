require 'rails_helper'

RSpec.describe WeatherKey do
  it 'builds day-level key with date and city' do
    t = Time.utc(2024, 1, 1, 8, 40)
    key = WeatherKey.key_for(city: 'Санкт-Петербург', at: t)
    expect(key).to eq('weather/Санкт-Петербург/2024-01-01')
  end

  it 'computes 20-minute time slot' do
    t = Time.utc(2024, 1, 1, 8, 7)
    slot = WeatherKey.time_slot_for(at: t)
    expect(slot).to eq('08:00')
  end
end
