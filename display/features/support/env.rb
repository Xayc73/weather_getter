ENV['RAILS_ENV'] = 'test'
require 'cucumber/rails'

# Run the Rails app in-process for faster, more reliable tests and to allow stubbing
Capybara.run_server = true
Capybara.app_host = nil
Capybara.default_driver = :rack_test
