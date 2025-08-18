# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../main'
require_relative '../lib/storage/in_memory'

RSpec.describe WeatherFetcher do
  describe '#fetch_and_store' do
    subject(:fetch_and_store) do
      described_class.new(cities: cities, provider: provider, storage: storage).fetch_and_store
    end

    let(:storage) { Storage::InMemoryAdapter.new }
    let(:cities) { %w[Москва Санкт-Петербург] }
    let(:fixed_time) { Time.utc(2024, 1, 1, 10, 7, 12) }

    before do
      allow(Time).to receive(:now).and_return(fixed_time)

      stub_geocoding_for('Москва', 55.7558, 37.6176)
      stub_geocoding_for('Санкт-Петербург', 59.9343, 30.3351)
    end

    def expected_key_for(city)
      "weather/#{city}/2024-01-01/10:00" # Fixed time: 10:07 -> 10:00
    end

    def parse_value(json)
      JSON.parse(json)
    end

    shared_examples 'common provider behavior' do
      it 'fetches temperatures and stores them with correct keys and values' do
        fetch_and_store

        cities.each do |city|
          key = expected_key_for(city)
          expect(storage.data).to have_key(key)
          payload = parse_value(storage.data[key])
          expect(payload['city']).to eq(city)
          expect(payload['at']).to eq(fixed_time.utc.iso8601)
          expect(payload['temp']).to eq(expected_temp[city])
        end
      end

      context 'when provider raises for one city' do
        before do
          allow(provider).to receive(:temperature_for).with('Москва').and_raise(StandardError, 'boom')
          allow(provider).to receive(:temperature_for).with('Санкт-Петербург').and_return(12.3)
        end

        it 'continues processing other cities' do
          expect { fetch_and_store }.not_to raise_error
          expect(storage.data.keys).to include(match(%r{^weather/Санкт-Петербург/}))
        end
      end
    end

    context 'with Open-Meteo provider' do
      let(:provider) { Weather::ProviderFactory.build('provider' => 'open_meteo') }
      let(:expected_temp) { { 'Москва' => 21.3, 'Санкт-Петербург' => 10.1 } }

      before do
        stub_request(:get, 'https://api.open-meteo.com/v1/forecast')
          .with(query: hash_including('latitude' => '55.7558', 'longitude' => '37.6176'))
          .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                     body: { current_weather: { temperature: expected_temp['Москва'] } }.to_json)

        stub_request(:get, 'https://api.open-meteo.com/v1/forecast')
          .with(query: hash_including('latitude' => '59.9343', 'longitude' => '30.3351'))
          .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                     body: { current_weather: { temperature: expected_temp['Санкт-Петербург'] } }.to_json)
      end

      it_behaves_like 'common provider behavior'
    end

    context 'with OpenWeather provider' do
      let(:config) do
        {
          'provider' => 'open_weather',
          'providers' => { 'open_weather' => { 'api_key' => 'test-key' } }
        }
      end
      let(:provider) { Weather::ProviderFactory.build(config) }
      let(:expected_temp) { { 'Москва' => 21.3, 'Санкт-Петербург' => 10.1 } }

      before do
        stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
          .with(query: hash_including('lat' => '55.7558', 'lon' => '37.6176', 'appid' => 'test-key'))
          .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                     body: { main: { temp: expected_temp['Москва'] } }.to_json)

        stub_request(:get, 'https://api.openweathermap.org/data/2.5/weather')
          .with(query: hash_including('lat' => '59.9343', 'lon' => '30.3351', 'appid' => 'test-key'))
          .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                     body: { main: { temp: expected_temp['Санкт-Петербург'] } }.to_json)
      end

      it_behaves_like 'common provider behavior'
    end
  end
end
