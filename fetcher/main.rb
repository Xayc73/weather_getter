require 'yaml'
require 'json'
require 'time'
require 'nats/io'
require 'rufus-scheduler'
require 'http'

class WeatherFetcher
  def initialize(nats_url:, cities:)
    @nats_url = nats_url
    @cities = cities
    @nc = NATS::IO::Client.new
    @nc.connect(url: @nats_url, max_reconnect_attempts: -1)
    @js = @nc.jetstream
    ensure_kv('weather')
    @kv = @js.key_value('weather')
  end

  def run
    scheduler = Rufus::Scheduler.new
    # Align to the next 20-minute boundary
    now = Time.now
    delay_seconds = seconds_until_next_boundary(now)
    scheduler.in "#{delay_seconds}s" do
      fetch_and_store
      scheduler.every '20m' do
        fetch_and_store
      end
    end
    scheduler.join
  end

  def fetch_and_store
    @cities.each do |city|
      temp = fetch_temperature_stub(city)
      key = key_for(city: city, at: Time.now)
      value = { city: city, at: Time.now.utc.iso8601, temp: temp }.to_json
      @kv.put(key, value)
      puts "Stored #{city} #{temp}C at #{Time.now}"
    end
  rescue StandardError => e
    warn "Fetch error: #{e.class} #{e.message}"
  end

  def close
    @nc.close
  end

  private

  # Replace with real API call(s) if desired
  def fetch_temperature_stub(city)
    # deterministic pseudo-random based on city and current 20-min slot
    slot = (Time.now.to_i / (20 * 60))
    base = city.bytes.sum % 15
    ((Math.sin(slot) * 10) + base - 5).round(1)
  end

  def ensure_kv(bucket)
    @js.key_value(bucket)
  rescue NATS::IO::NoRespondersError, NATS::IO::Error
    @js.create_key_value(bucket: bucket)
  end

  def key_for(city:, at:)
    rounded = Time.at((at.to_i / (20 * 60)) * 20 * 60)
    date = rounded.utc.strftime('%Y-%m-%d')
    time = rounded.utc.strftime('%H:%M')
    "weather/#{city}/#{date}/#{time}"
  end

  def seconds_until_next_boundary(now)
    slot = (now.to_i / (20 * 60)) * 20 * 60
    next_slot = slot + 20 * 60
    [next_slot - now.to_i, 0].max
  end
end

def load_cities
  path = File.join(__dir__, 'config', 'cities.yml')
  yaml = YAML.load_file(path)
  yaml['default_cities'] || []
end

if __FILE__ == $0
  nats_url = ENV.fetch('NATS_URL', 'nats://localhost:4222')
  cities = load_cities
  fetcher = WeatherFetcher.new(nats_url: nats_url, cities: cities)
  trap('TERM') do
    fetcher.close
    exit
  end
  trap('INT') do
    fetcher.close
    exit
  end
  fetcher.run
end
