# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../lib/weather/provider_factory'

RSpec.describe Weather::ProviderFactory do
  context 'when no provider specified' do
    it 'builds open_meteo by default' do
      provider = described_class.build({})
      expect(provider).to be_a(Weather::Providers::OpenMeteo)
    end
  end

  context 'when provider is open_weather' do
    it 'configures client with api_key and returns provider' do
      provider = described_class.build('provider' => 'open_weather',
                                       'providers' => { 'open_weather' => { 'api_key' => 'k' } })
      expect(provider).to be_a(Weather::Providers::OpenWeather)
      expect(Weather::Clients::OpenWeatherClient.instance.api_key).to eq('k')
    end
  end

  context 'when provider is unknown' do
    it 'raises error' do
      expect { described_class.build('provider' => 'unknown') }.to raise_error(ArgumentError, /Unknown provider/)
    end
  end
end
