# frozen_string_literal: true
module RelatedManuscriptsHelper
  # Renders a single related_mss[].mss[] entry. When the entry references a
  # SMDL record (`id` present), we look up the linked record's shelfmark in
  # Solr and use it as the link text -- the inline `label` in the source JSON
  # is often a generic placeholder, while the real shelfmark is what users
  # need to see. Falls back to the inline label if the ARK isn't indexed.
  # External-URL entries and plain-text entries still use the inline label.
  def render_related_mss_link(mss_item)
    label = mss_item['label'].to_s
    if mss_item['id'].present?
      ark = mss_item['id']
      shelfmark = solr_shelfmark_for_ark(ark).presence || label
      link_to shelfmark, solr_document_path(ark)
    elsif mss_item['url'].present?
      link_to label, mss_item['url'], target: '_blank', rel: 'noopener'
    else
      h(label)
    end
  end

  # Renders a single reconstructed_from[] entry. feed_ursus enriches the source
  # JSON's flat ARK list into objects of the form { id: ARK, shelfmark: string }.
  def render_reconstructed_from_link(entry)
    ark       = entry['id']
    shelfmark = entry['shelfmark'].to_s.presence || ark.to_s
    return h(shelfmark) if ark.blank?
    link_to shelfmark, solr_document_path(ark)
  end

  # Reverse lookup: returns an array of { id:, shelfmark: } for every Solr
  # record that lists `ark` in its `reconstructed_from_ssim` field. Memoized
  # per-request so the tab-presence check and the partial don't double-query.
  def manuscripts_including_in_reconstruction(ark)
    return [] if ark.blank?
    @_included_in_reconstructions ||= {}
    @_included_in_reconstructions[ark] ||= included_in_solr_lookup(ark)
  end

  private

    def included_in_solr_lookup(ark)
      params = { q: %(reconstructed_from_ssim:"#{ark}"), fl: 'id,shelfmark_ssi', rows: 100 }
      response = Blacklight.default_index.connection.get('select', params: params)
      Array(response.dig('response', 'docs')).map do |doc|
        { id: doc['id'], shelfmark: Array(doc['shelfmark_ssi']).first.presence || doc['id'] }
      end
    end

    # Memoized lookup of a record's shelfmark by ARK. Returns nil if the ARK
    # isn't indexed (e.g. references an external/non-Sinai manuscript).
    def solr_shelfmark_for_ark(ark)
      @_shelfmark_for_ark ||= {}
      return @_shelfmark_for_ark[ark] if @_shelfmark_for_ark.key?(ark)

      params = { q: %(id:"#{ark}"), fl: 'shelfmark_ssi', rows: 1 }
      response = Blacklight.default_index.connection.get('select', params: params)
      doc = Array(response.dig('response', 'docs')).first
      @_shelfmark_for_ark[ark] = doc ? Array(doc['shelfmark_ssi']).first : nil
    end
end
