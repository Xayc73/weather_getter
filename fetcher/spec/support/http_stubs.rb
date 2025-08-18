# frozen_string_literal: true

module HttpStubs
  def stub_geocoding_for(city, latitude, longitude)
    stub_request(:get, 'https://geocoding-api.open-meteo.com/v1/search')
      .with(query: hash_including('name' => city, 'count' => '3', 'language' => 'ru', 'format' => 'json'))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: { results: [{ latitude: latitude, longitude: longitude }] }.to_json
      )
  end

  def stub_open_meteo_weather(temperature:)
    stub_request(:get, 'https://api.open-meteo.com/v1/forecast')
      .with(query: hash_including('current_weather' => 'true', 'timezone' => 'UTC'))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: { current_weather: { temperature: temperature } }.to_json
      )
  end

  def stub_open_weather_weather(temp:, api_key: nil)
    matcher = api_key ? hash_including('units' => 'metric', 'appid' => api_key) : hash_including('units' => 'metric')
    stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
      .with(query: matcher)
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: { main: { temp: temp } }.to_json
      )
  end
end

RSpec.configure do |config|
  config.include HttpStubs
end
