require_relative 'base'
require_relative 'panopticon/registerer'
require_relative 'exceptions'

class GdsApi::Panopticon < GdsApi::Base

  include GdsApi::ExceptionHandling

  def all
    uri = build_uri('artefacts.json')
    json = get_json(uri)
    to_ostruct(json)
  end

  def artefact_for_slug(slug, opts = {})
    return nil if slug.nil? or slug == ''
    get_json(url_for_slug(slug, segments: ['artefacts']))
  end

  def create_artefact(artefact)
    ignoring GdsApi::HTTPErrorResponse do
      create_artefact! artefact
    end
  end

  def create_artefact!(artefact)
    post_json!(build_uri("artefacts.json"), artefact)
  end

  def put_artefact(id_or_slug, artefact)
    ignoring GdsApi::HTTPErrorResponse do
      put_artefact!(id_or_slug, artefact)
    end
  end

  def put_artefact!(id_or_slug, artefact)
    uri = build_uri("#{id_or_slug}.json", segments: ['artefacts'])
    put_json!(uri, artefact)
  end

  def update_artefact(id_or_slug, artefact)
    self.class.logger.warn(
      "The update_artefact method is deprecated and may be removed in a " +
      "future release. You should use put_artefact instead."
    )
    put_artefact(id_or_slug, artefact)
  end

  def delete_artefact!(id_or_slug)
    delete_json!(build_uri("#{id_or_slug}.json", segments: ['artefacts']))
  end
end
