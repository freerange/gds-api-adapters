require 'test_helper'
require 'gds_api/base'
require 'uri'

class GdsApiBaseTest < Minitest::Test

  class ConcreteApi < GdsApi::Base
    def base_url
      endpoint
    end
  end

  def setup
    @orig_cache = GdsApi::JsonClient.cache
  end

  def teardown
    GdsApi::JsonClient.cache = @orig_cache
  end

  def test_should_construct_escaped_query_string
    api = ConcreteApi.new('http://foo')
    url = api.url_for_slug("slug", "a" => " ", "b" => "/")
    u = URI.parse(url)
    assert_equal "a=+&b=%2F", u.query
  end

  def test_should_construct_escaped_query_string_for_rails
    api = ConcreteApi.new('http://foo')

    url = api.url_for_slug("slug", "b" => ['123'])
    u = URI.parse(url)
    assert_equal "b%5B%5D=123", u.query

    url = api.url_for_slug("slug", "b" => ['123', '456'])
    u = URI.parse(url)
    assert_equal "b%5B%5D=123&b%5B%5D=456", u.query
  end

  def test_should_not_add_a_question_mark_if_there_are_no_parameters
    api = ConcreteApi.new('http://foo')
    url = api.url_for_slug("slug")
    refute_match /\?/, url
  end

  def test_should_use_endpoint_in_url
    api = ConcreteApi.new("http://foobarbaz")
    url = api.url_for_slug("slug")
    u = URI.parse(url)
    assert_match /foobarbaz$/, u.host
  end

  def test_should_accept_options_as_second_arg
    api = ConcreteApi.new("http://foo", {foo: "bar"})
    assert_equal "bar", api.options[:foo]
  end

  def test_setting_cache_size_from_options
    GdsApi::JsonClient.cache = false
    api = ConcreteApi.new("https://foo", {cache_size: 2})
    assert_equal 2, api.client.cache.max_size
  end

  def test_setting_cache_size_from_default_options
    GdsApi::JsonClient.cache = false
    GdsApi::Base.default_options = {cache_size: 4}
    api = ConcreteApi.new("http://bar")
    assert_equal 4, api.client.cache.max_size
  end

  def test_disabling_cache
    # Ensure that there is a non-null cache by default
    GdsApi::JsonClient.cache = true
    api = ConcreteApi.new("http://bar", disable_cache: true)
    assert api.client.cache.is_a? GdsApi::NullCache
  end

  def test_disabling_cache_old_style
    # Ensure that there is a non-null cache by default
    GdsApi::JsonClient.cache = true
    api = ConcreteApi.new("http://bar", cache_size: 0)
    assert api.client.cache.is_a? GdsApi::NullCache
  end

  def test_should_barf_if_not_given_valid_URL
    proc do
      ConcreteApi.new('invalid-url')
    end.must_raise GdsApi::Base::InvalidAPIURL
  end
end
