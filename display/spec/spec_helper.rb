require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter %r{^/spec/}
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


