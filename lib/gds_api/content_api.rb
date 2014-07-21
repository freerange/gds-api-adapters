require_relative 'base'
require_relative 'exceptions'
require_relative 'list_response'

class GdsApi::ContentApi < GdsApi::Base

  def initialize(endpoint_url, options = {})
    # If the `web_urls_relative_to` option is given, the adapter will convert
    # any `web_url` values to relative URLs if they are from the same host.
    #
    # For example: "https://www.gov.uk"

    @web_urls_relative_to = options.delete(:web_urls_relative_to)
    super
  end

  def sections
    tags("section")
  end

  def root_sections
    root_tags("section")
  end

  def sub_sections(parent_tag)
    child_tags("section", parent_tag)
  end

  def tags(tag_type, options={})
    params = {type: tag_type}
    params.merge!(sort: options[:sort]) if options[:sort]

    get_list!(build_uri('tags.json', params: params))
  end

  def root_tags(tag_type)
    uri = build_uri('tags.json', params: {
      type: tag_type,
      root_sections: true
    })

    get_list!(uri)
  end

  def child_tags(tag_type, parent_tag, options={})
    params = {
      type: tag_type,
      parent_id: parent_tag
    }
    params.merge!(sort: options[:sort]) if options[:sort]

    get_list!(build_uri('tags.json', params: params))
  end

  def tag(tag, tag_type=nil)
    segments = ['tags']
    segments << tag_type if tag_type

    get_json(build_uri("#{tag}.json", segments: segments))
  end

  def with_tag(tag, tag_type=nil, options={})
    tag_key = key_for_tag_type(tag_type)

    params = {tag_key => tag}
    params.merge!(group_by: options[:group_by]) if options[:group_by]

    get_list!(build_uri('with_tag.json', params: params))
  end

  def curated_list(tag, tag_type=nil)
    tag_key = key_for_tag_type(tag_type)

    get_list(build_uri('with_tag.json', params: {tag_key => tag, sort: 'curated'}))
  end

  def sorted_by(tag, sort_by, tag_type=nil)
    tag_key = key_for_tag_type(tag_type)

    get_list(build_uri('with_tag.json', params: {tag_key => tag, sort: sort_by}))
  end

  def for_need(need_id)
    get_list(build_uri("#{need_id}.json", segments: ['for_need']))
  end

  def artefact(slug, params={})
    get_json(artefact_url(slug, params))
  end

  def artefact!(slug, params={})
    get_json!(artefact_url(slug, params))
  end

  def artefacts
    get_list!(build_uri("artefacts.json"))
  end

  def local_authority(snac_code)
    get_json(build_uri("#{snac_code}.json", segments: ['local_authorities']))
  end

  def local_authorities_by_name(name)
    get_json!(build_uri("local_authorities.json", params: {name: name}))
  end

  def local_authorities_by_snac_code(snac_code)
    get_json!(build_uri("local_authorities.json", params: {snac_code: snac_code}))
  end

  def licences_for_ids(ids)
    ids = ids.map(&:to_s).sort.join(',')
    get_json("#{@endpoint}/licences.json?ids=#{ids}")
  end

  def business_support_schemes(facets)
    get_json!(build_uri("business_support_schemes.json", params: facets))
  end

  def get_list!(url)
    get_json!(url) { |r|
      GdsApi::ListResponse.new(r, self, web_urls_relative_to: @web_urls_relative_to)
    }
  end

  def get_list(url)
    get_json(url) { |r|
      GdsApi::ListResponse.new(r, self, web_urls_relative_to: @web_urls_relative_to)
    }
  end

  def get_json(url, &create_response)
    create_response = create_response || Proc.new { |r|
      GdsApi::Response.new(r, web_urls_relative_to: @web_urls_relative_to)
    }
    super(url, &create_response)
  end

  def get_json!(url, &create_response)
    create_response = create_response || Proc.new { |r|
      GdsApi::Response.new(r, web_urls_relative_to: @web_urls_relative_to)
    }
    super(url, &create_response)
  end

  private
    def key_for_tag_type(tag_type)
      tag_type || 'tag'
    end

    def artefact_url(slug, params)
      if params[:edition] && !options.include?(:bearer_token)
        raise GdsApi::NoBearerToken
      end

      build_uri("#{slug}.json", params: params)
    end
end
