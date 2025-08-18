# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/weather/coordinates_resolver'
require_relative '../../lib/storage/in_memory'

RSpec.describe Weather::CoordinatesResolver do
  let(:storage) { Storage::InMemoryAdapter.new }

  before { described_class.configure(storage: storage) }

  context 'when storage not configured' do
    before { described_class.instance.instance_variable_set(:@storage, nil) }

    it 'raises exception' do
      expect { described_class.resolve('Москва') }.to raise_error(RuntimeError, /configured/)
    end
  end

  context 'when cache has coordinates' do
    before do
      storage.put(key: 'geocode/%D0%9C%D0%BE%D1%81%D0%BA%D0%B2%D0%B0', value: { 'latitude' => 1, 'longitude' => 2 })
    end

    it 'reads coordinates from cache' do
      expect(described_class.resolve('Москва')).to eq({ 'latitude' => 1, 'longitude' => 2 })
    end
  end

  context 'when cache miss and geocoding succeeds' do
    let(:frozen_time) { Time.utc(2024, 1, 1, 10, 0, 0) }

    before do
      allow(Time).to receive(:now).and_return(frozen_time)
      stub_geocoding_for('Москва', 55.7558, 37.6176)
    end

    it 'geocodes and writes to cache' do
      result = described_class.resolve('Москва')
      expect(result).to eq({ latitude: 55.7558, longitude: 37.6176 })

      raw = storage.get(key: 'geocode/%D0%9C%D0%BE%D1%81%D0%BA%D0%B2%D0%B0')
      json = raw.is_a?(String) ? JSON.parse(raw) : raw
      expect(json['latitude']).to eq(55.7558)
      expect(json['longitude']).to eq(37.6176)
      expect(json['updated_at']).to eq(frozen_time.utc.iso8601)
    end
  end

  context 'when geocoding returns empty results' do
    before do
      stub_request(:get, 'https://geocoding-api.open-meteo.com/v1/search')
        .with(query: hash_including('name' => 'Москва'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { results: [] }.to_json)
    end

    it 'returns nil' do
      expect(described_class.resolve('Москва')).to be_nil
    end
  end

  context 'when cache contains invalid JSON' do
    before do
      storage.put(key: 'geocode/%D0%9C%D0%BE%D1%81%D0%BA%D0%B2%D0%B0', value: '{invalid json')
      stub_geocoding_for('Москва', 55.7558, 37.6176)
    end

    it 'falls back to geocoding' do
      expect(described_class.resolve('Москва')).to eq({ latitude: 55.7558, longitude: 37.6176 })
    end
  end
end
