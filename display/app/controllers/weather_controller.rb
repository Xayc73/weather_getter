class WeatherController < ApplicationController
  DEFAULT_CITIES = "Москва,Санкт-Петербург"

  def index
    @cities = ENV.fetch("DEFAULT_CITIES", DEFAULT_CITIES).split(",").map(&:strip)
    @temperatures_by_city = WeatherService.new.fetch_temperatures(@cities)
  end
end
