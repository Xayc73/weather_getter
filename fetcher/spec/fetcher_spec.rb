require 'rspec'
require_relative '../main'

RSpec.describe WeatherFetcher do
  it 'builds deterministic key format' do
    wf = WeatherFetcher.allocate
    t = Time.utc(2024, 1, 1, 10, 7)
    key = wf.send(:key_for, city: 'Москва', at: t)
    expect(key).to eq('weather/Москва/2024-01-01/10:00')
  end
end


