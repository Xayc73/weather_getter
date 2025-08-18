# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]

SimpleCov.start do
  enable_coverage :branch
  add_filter '/spec/'
  add_filter '/vendor/'
  track_files 'lib/**/*.rb'
end

require 'rspec'
require 'webmock/rspec'
require 'json'

WebMock.disable_net_connect!(allow_localhost: true)

Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
end
