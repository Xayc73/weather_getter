# frozen_string_literal: true

# Test stub to avoid external NATS dependency during Cucumber runs
if defined?(Rails) && Rails.env.test?
  class FakeNatsClient
    def read_kv(bucket:, key:)
      nil
    end

    def close; end
  end

  class NatsClient
    def self.new(*_args)
      @fake_client ||= FakeNatsClient.new
    end
  end
end
