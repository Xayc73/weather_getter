# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/weather/clients/open_weather_client'

RSpec.describe Weather::Clients::OpenWeatherClient do
  context 'when api_key is not configured' do
    before do
      described_class.instance.instance_variable_set(:@api_key, nil)
    end

    it 'raises exception' do
      expect do
        described_class.current_weather(latitude: 55.75, longitude: 37.61)
      end.to raise_error(ArgumentError, /api_key/i)
    end
  end

  context 'when api_key is configured' do
    before do
      described_class.configure(api_key: 'k')
      stub_open_weather_weather(temp: 19.1, api_key: 'k')
    end

    it 'returns parsed body' do
      body = described_class.current_weather(latitude: 55.75, longitude: 37.61)
      expect(body.dig('main', 'temp')).to eq(19.1)
    end
  end
end
