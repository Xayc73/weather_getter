# frozen_string_literal: true

require_relative 'nats_kv_adapter'

module Storage
  class Factory
    def self.build(config = {})
      selected = (config.dig('storage', 'adapter') || ENV['STORAGE_ADAPTER'] || 'nats_kv').to_s

      case selected
      when 'nats_kv'
        nats_url = ENV.fetch('NATS_URL', 'nats://localhost:4222')
        bucket   = config.dig('storage', 'nats_kv', 'bucket') || 'weather'
        Storage::NatsKvAdapter.new(nats_url: nats_url, bucket: bucket)
      else
        raise ArgumentError, "Unknown storage adapter: #{selected}"
      end
    end
  end
end
