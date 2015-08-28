require_relative 'base'
require_relative 'exceptions'

class GdsApi::Mapit < GdsApi::Base

  def location_for_postcode(postcode)
    response = get_json("#{base_url}/postcode/#{CGI.escape postcode}.json")
    return Location.new(response) unless response.nil?
  rescue GdsApi::HTTPErrorResponse => e
    # allow 400 errors, as they can be invalid postcodes people have entered
    raise e unless e.code == 400
  end

  def location_for_partial_postcode(outcode)
    partial = get_json("#{base_url}/postcode/partial/#{CGI.escape outcode}.json")
    point = get_json("#{base_url}/point/27700/#{partial.easting},#{partial.northing}.json")

    response = partial.to_h
    response['areas'] = point.to_h

    return Location.new(response) unless response.nil?
  rescue GdsApi::HTTPErrorResponse => e
    # allow 400 errors, as they can be invalid postcodes people have entered
    raise e unless e.code == 400
  end

  def areas_for_type(type)
    get_json("#{base_url}/areas/#{type}.json")
  end

  class Location
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def lat
      @response['wgs84_lat']
    end

    def lon
      @response['wgs84_lon']
    end

    def areas
      @response['areas'].map {|i, area| OpenStruct.new(area) }
    end

    def postcode
      @response['postcode']
    end
  end

  private
    def base_url
      endpoint
    end

end
