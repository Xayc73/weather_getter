require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:storage) { double(close: true) }

  describe '#build_time_slots' do
    it 'builds time slots from start of day to now with 20-minute step' do
      current_time = Time.utc(2024, 1, 1, 8, 7)
      service = WeatherService.new(storage: storage, time_source: -> { current_time })

      slots = service.build_time_slots

      expect(slots.first).to eq(Time.utc(2024, 1, 1, 0, 0))
      expect(slots.last <= current_time).to be true
      expect(slots[1] - slots[0]).to eq(20.minutes)
      expect(slots[2] - slots[1]).to eq(20.minutes)
    end

    it 'at exactly midnight includes only the start of day slot' do
      current_time = Time.utc(2024, 1, 1, 0, 0)
      service = WeatherService.new(storage: storage, time_source: -> { current_time })

      slots = service.build_time_slots

      expect(slots).to eq([ Time.utc(2024, 1, 1, 0, 0) ])
    end
  end

  describe '#fetch_temperatures' do
    let(:cities) { [ 'Москва', 'Санкт-Петербург' ] }

    it 'drops leading nil temperatures but keeps at least last slot' do
      current_time = Time.utc(2024, 1, 1, 0, 35)
      service = WeatherService.new(storage: storage, time_source: -> { current_time })
      allow(storage).to receive(:read_temperatures_batch) do |city:, at_times:|
        Array.new(at_times.length, nil)
      end

      temps_by_city = service.fetch_temperatures(cities)

      readings = temps_by_city[cities.first]
      expect(readings.size).to eq(1)
      expect(readings.first.last).to be_nil
    end

    it 'trims only leading nils, keeping first value and following nils' do
      current_time = Time.utc(2024, 1, 1, 0, 40)
      service = WeatherService.new(storage: storage, time_source: -> { current_time })
      # For the first city return [nil, 1, nil], for the second city all nils
      allow(storage).to receive(:read_temperatures_batch) do |city:, at_times:|
        if city == cities.first
          [ nil, 1, nil ]
        else
          Array.new(at_times.length, nil)
        end
      end

      temps_by_city = service.fetch_temperatures(cities)

      readings = temps_by_city[cities.first]
      expect(readings.map(&:last)).to eq([ 1, nil ])
      expect(readings.first.first).to eq(Time.utc(2024, 1, 1, 0, 20))
    end
  end
end
