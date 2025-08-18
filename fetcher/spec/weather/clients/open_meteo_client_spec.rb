# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/weather/clients/open_meteo_client'

RSpec.describe Weather::Clients::OpenMeteoClient do
  context 'when request is successful' do
    before { stub_open_meteo_weather(temperature: 21.3) }

    it 'returns parsed body' do
      body = described_class.current_weather(latitude: 55.75, longitude: 37.61)
      expect(body.dig('current_weather', 'temperature')).to eq(21.3)
    end
  end
end
