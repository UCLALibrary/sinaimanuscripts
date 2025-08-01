# frozen_string_literal: true

class IiifService
  def src(request, document)
    "#{media_viewer_url(request)}?site=sinai&manifest=#{CGI.escape(iiif_manifest_url(document))}"
    # "http://localhost:8080/?site=sinai&manifest=#{CGI.escape(iiif_manifest_url(document))}"
    # "https://d-w-dl-viewer01.library.ucla.edu?site=sinai&manifest=#{CGI.escape(iiif_manifest_url(document))}"
  end

  def iiif_manifest_url(document)
    document[:iiif_manifest_url_ssi].sub('http:', 'https:').sub('ingest.iiif.library.ucla.edu', 'iiif.library.ucla.edu')
  end

  def media_viewer_url(request)
    case request.query_parameters['media_viewer_url']
    when nil
      Rails.application.config.media_viewer_url
    when 'dev', 'test', 'stage', 'prod'
      'https://' + request.query_parameters['viewer'][0] + '-w-dl-viewer01.library.ucla.edu'
    else
      request.query_parameters['viewer']
    end
  end
end
