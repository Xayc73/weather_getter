# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/weather/providers/open_meteo'
require_relative '../../../lib/weather/coordinates_resolver'

RSpec.describe Weather::Providers::OpenMeteo do
  context 'when temperature present' do
    before do
      allow(Weather::CoordinatesResolver).to receive(:resolve).with('Москва').and_return({ 'latitude' => 1,
                                                                                           'longitude' => 2 })
      stub_open_meteo_weather(temperature: 21.3)
    end

    it 'returns temperature as float' do
      provider = described_class.new
      expect(provider.temperature_for('Москва')).to eq(21.3)
    end
  end

  context 'when temperature missing' do
    before do
      allow(Weather::CoordinatesResolver).to receive(:resolve).and_return({ 'latitude' => 1, 'longitude' => 2 })
      stub_request(:get, 'https://api.open-meteo.com/v1/forecast')
        .with(query: hash_including('current_weather' => 'true', 'timezone' => 'UTC'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                   body: { current_weather: {} }.to_json)
    end

    it 'returns nil' do
      provider = described_class.new
      expect(provider.temperature_for('Москва')).to be_nil
    end
  end
end
