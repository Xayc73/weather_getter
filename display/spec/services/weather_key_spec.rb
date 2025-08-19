require 'rails_helper'

RSpec.describe WeatherKey do
  it 'rounds time to 20-minute slot' do
    t = Time.utc(2024, 1, 1, 8, 7)
    key = WeatherKey.key_for(city: 'Москва', at: t)
    expect(key).to include('/08:00')
  end

  it 'formats with date and city' do
    t = Time.utc(2024, 1, 1, 8, 40)
    key = WeatherKey.key_for(city: 'Санкт-Петербург', at: t)
    expect(key).to eq('weather/Санкт-Петербург/2024-01-01/08:40')
  end
end
