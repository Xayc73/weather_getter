# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/weather/providers/open_weather'
require_relative '../../../lib/weather/provider_factory'
require_relative '../../../lib/weather/coordinates_resolver'

RSpec.describe Weather::Providers::OpenWeather do
  before do
    Weather::Clients::OpenWeatherClient.configure(api_key: 'k')
  end

  context 'when temperature present' do
    before do
      allow(Weather::CoordinatesResolver).to receive(:resolve).with('Москва').and_return({ 'latitude' => 1,
                                                                                           'longitude' => 2 })
      stub_open_weather_weather(temp: 18.7, api_key: 'k')
    end

    it 'returns temperature as float' do
      provider = described_class.new
      expect(provider.temperature_for('Москва')).to eq(18.7)
    end
  end

  context 'when temperature missing' do
    before do
      allow(Weather::CoordinatesResolver).to receive(:resolve).and_return({ 'latitude' => 1, 'longitude' => 2 })
      stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
        .with(query: hash_including('units' => 'metric', 'appid' => 'k'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { main: {} }.to_json)
    end

    it 'returns nil' do
      provider = described_class.new
      expect(provider.temperature_for('Москва')).to be_nil
    end
  end
end
