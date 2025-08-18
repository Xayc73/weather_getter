# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../lib/weather/clients/open_meteo_geocoding_client'

RSpec.describe Weather::Clients::OpenMeteoGeocodingClient do
  context 'when request is successful' do
    before { stub_geocoding_for('Москва', 55.7558, 37.6176) }

    it 'returns parsed body' do
      body = described_class.geocode_city('Москва', count: 3, lang: 'ru')
      first = body['results'].first
      expect(first['latitude']).to eq(55.7558)
      expect(first['longitude']).to eq(37.6176)
    end
  end
end
