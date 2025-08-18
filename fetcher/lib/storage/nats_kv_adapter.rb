# frozen_string_literal: true

require 'nats/client'
require_relative 'adapter'

module Storage
  class NatsKvAdapter < Adapter
    def initialize(nats_url:, bucket: 'weather')
      super()
      @nats_url = nats_url
      @bucket = bucket
      @nc = NATS.connect(@nats_url)
      @js = @nc.jetstream
      ensure_kv(@bucket)
      @kv = @js.key_value(@bucket)
    end

    def get(key:)
      entry = @kv.get(key)
      entry&.value
    rescue NATS::KeyValue::KeyNotFoundError, NATS::JetStream::Error, NATS::Error
      nil
    end

    def put(key:, value:)
      @kv.put(key, value)
    end

    def close
      @nc.close
    end

    private

    def ensure_kv(bucket)
      @js.key_value(bucket)
    rescue StandardError
      @js.create_key_value(bucket: bucket)
    end
  end
end
