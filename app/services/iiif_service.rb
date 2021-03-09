# frozen_string_literal: true

class IiifService
  def src(request, document)
    "#{request&.base_url}/mirador.html#?manifest=#{CGI.escape(iiif_manifest_url(document))}"
  end

  def iiif_manifest_url(document)
    if Flipflop.use_manifest_store? && document[:iiif_manifest_url_ssi]
      document[:iiif_manifest_url_ssi].sub('http:', 'https:')
    else
      "#{Rails.application.config.iiif_url}/#{document.id}/manifest"
    end
  end
end
