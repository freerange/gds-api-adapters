require 'json'
require 'net/http'
require 'ostruct'
require_relative 'core-ext/openstruct'
require_relative 'version'
require_relative 'exceptions'

module GdsApi::JsonUtils
  TIMEOUT_IN_SECONDS = 0.5
  STANDARD_HEADERS = {
    'Accept' => 'application/json', 
    'Content-Type' => 'application/json', 
    'User-Agent' => "GDS Api Client v. #{GdsApi::VERSION}"
  }

  def process_response(response, url)
    if response.timed_out?
      raise GdsApi::TimedOut
    elsif response.success?
      JSON.parse(response.body)
    elsif response.code == 404
      return nil
    else
      raise GdsApi::EndpointNotFound.new("Could not connect to #{url}")
    end
  end

  def do_request(url, verb, params = {})
    request = Typhoeus::Request.new(url,
      :method        => verb,
      :body          => params.any? ? params.to_json : nil,
      :headers       => STANDARD_HEADERS,
      :timeout       => TIMEOUT_IN_SECONDS * 1000, # milliseconds
      :cache_timeout => 60 # seconds
    )

    hydra = Typhoeus::Hydra.new
    hydra.queue(request)
    hydra.run

    process_response(request.response, url)
  rescue Errno::ECONNREFUSED
    raise GdsApi::EndpointNotFound.new("Could not connect to #{url}")
  end

  def get_json(url)
    do_request(url, :get)
  end

  def post_json(url, params)
    do_request(url, :post, params)
  end

  def to_ostruct(object)
    case object
    when Hash
      OpenStruct.new Hash[object.map { |key, value| [key, to_ostruct(value)] }]
    when Array
      object.map { |k| to_ostruct(k) }
    else
      object
    end
  end
end
