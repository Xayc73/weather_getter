# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/weather/city_coordinates'
require_relative '../../lib/weather/coordinates_resolver'

RSpec.describe Weather::CityCoordinates do
  context 'when preloading cities' do
    before do
      allow(Weather::CoordinatesResolver).to receive(:resolve)
      described_class.preload_cities(%w[a b c])
    end

    it 'calls resolver for each city' do
      expect(Weather::CoordinatesResolver).to have_received(:resolve).with('a')
      expect(Weather::CoordinatesResolver).to have_received(:resolve).with('b')
      expect(Weather::CoordinatesResolver).to have_received(:resolve).with('c')
    end
  end

  context 'when getting a city' do
    before { allow(Weather::CoordinatesResolver).to receive(:resolve).and_return({}) }

    it 'delegates to resolver' do
      described_class.get('Москва')
      expect(Weather::CoordinatesResolver).to have_received(:resolve).with('Москва')
    end
  end
end
