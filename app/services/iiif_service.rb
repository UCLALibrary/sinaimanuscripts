# frozen_string_literal: true

class IiifService
  def src(request, document)
    "#{request&.base_url}?site=sinai&manifest=#{CGI.escape(iiif_manifest_url(document))}"
    # "http://localhost:8080/?site=sinai&manifest=#{CGI.escape(iiif_manifest_url(document))}"
    # "https://d-w-dl-viewer01.library.ucla.edu?site=sinai&manifest=#{CGI.escape(iiif_manifest_url(document))}"
  end

  def iiif_manifest_url(document)
    document[:iiif_manifest_url_ssi].sub('http:', 'https:')
  end
end
