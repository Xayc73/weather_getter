require "nats/client"

class NatsClient
  def initialize(url)
    @nc = NATS.connect(url)
    @js = @nc.jetstream
  end

  def read_kv(bucket:, key:)
    ensure_kv(bucket)
    kv = @js.key_value(bucket)
    entry = begin
      kv.get(key)
    rescue NATS::KeyValue::KeyNotFoundError, NATS::JetStream::Error, NATS::Error
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
  rescue StandardError
    @js.create_key_value(bucket: bucket)
  end
end
