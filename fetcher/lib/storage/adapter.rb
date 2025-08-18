# frozen_string_literal: true

module Storage
  class Adapter
    def get(key:)
      raise NotImplementedError, 'get must be implemented in subclasses'
    end

    def put(key:, value:)
      raise NotImplementedError, 'put must be implemented in subclasses'
    end

    def close
      # optional for adapters that maintain connections
    end
  end
end
