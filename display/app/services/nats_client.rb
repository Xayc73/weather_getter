require 'nats/io'

class NatsClient
  def initialize(url)
    @nc = NATS::IO::Client.new
    @nc.connect(url: url, max_reconnect_attempts: -1)
    @js = @nc.jetstream
  end

  def read_kv(bucket:, key:)
    ensure_kv(bucket)
    kv = @js.key_value(bucket)
    entry = begin
      kv.get(key)
    rescue StandardError
      nil
    end
    entry && entry.value
  end

  def close
    @nc&.close
  end

  private

  def ensure_kv(bucket)
    @js.key_value(bucket)
  rescue NATS::IO::NoRespondersError, NATS::IO::Error
    @js.create_key_value(bucket: bucket)
  end
end


