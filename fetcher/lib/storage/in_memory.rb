# frozen_string_literal: true

require_relative 'adapter'

# for testing purposes only
module Storage
  class InMemoryAdapter < Adapter
    attr_reader :data

    def initialize
      super
      @data = {}
    end

    def get(key:)
      @data[key]
    end

    def put(key:, value:)
      @data[key] = value
    end
  end
end
