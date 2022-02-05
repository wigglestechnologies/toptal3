module Joggings
  class WeatherService
    require 'rest-client'

    def initialize(jogging)
      @jogging = jogging
      @url = get_historical_url
    end

    def call
      @url.nil? ? destroy_weather : integrate_weather_api

    rescue RestClient::ExceptionWithResponse => e
      e.response
    end

    private

    def integrate_weather_api
      response = RestClient.get @url

      return if response.nil?
      forecast = JSON.parse(response)['forecast']['forecastday'][0]['day']
      temp_c = forecast['avgtemp_c']
      temp_f = forecast['avgtemp_f']
      weather_type = forecast['condition']['text']

      destroy_weather
      Weather.create(jogging_id: @jogging&.id, temp_c: temp_c, temp_f: temp_f, weather_type: weather_type)
    end

    # Free Weather API has access only 7 days in past
    def get_historical_url
      url = "#{WEATHER_HISTORICAL_API}?key=#{WEATHER_API_KEY}&q=#{@jogging&.lat},#{@jogging&.lon}&dt=#{@jogging&.date}"
      (@jogging && @jogging&.date >= DateTime.now - 7.days) ? url : nil
    end

    def destroy_weather
      Weather.where(jogging_id: @jogging&.id).first&.destroy
    end

  end
end
