require_relative 'base'

class GdsApi::PublishingApiV2 < GdsApi::Base

  def put_content(content_id, payload)
    put_json!(content_url(content_id), payload)
  end

  def get_content(content_id)
    get_json(content_url(content_id))
  end

  def publish(content_id, update_type)
    post_json!(content_url(content_id) + "/publish", {
      update_type: update_type,
    })
  end

  def get_links(content_id)
    get_json(links_url(content_id))
  end

  def put_links(content_id, payload)
    links = payload.fetch(:links)
    put_json!(links_url(content_id), links: links)
  end

private

  def content_url(content_id)
    "#{endpoint}/v2/content/#{content_id}"
  end

  def links_url(content_id)
    "#{endpoint}/v2/links/#{content_id}"
  end
end
