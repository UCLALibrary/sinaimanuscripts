# frozen_string_literal: true

# Helpers for the catalog index (search results) views.
module IndexResultsHelper
  # Origin date values (assoc_date[].value where type.id == 'origin') collected
  # from every level of the manuscript JSON blob: ms_obj, each part, and anywhere
  # within each part's ot_layer (layer_record + its paracontent). Mirrors the
  # Overview show page traversal (_item_overview_metadata.html.erb), but returns
  # date values only -- the index row shows dates, not date;place pairs.
  def sinai_index_origin_dates(document)
    assoc_date_arrays(parse_manuscript_json(document))
      .flatten.compact
      .select { |d| d.is_a?(Hash) && d.dig('type', 'id') == 'origin' }
      .map { |d| d['value'].to_s }.reject(&:blank?).uniq
  end

  private

    def parse_manuscript_json(document)
      JSON.parse(document['manuscript_json_ts'] || '{}')
    rescue StandardError
      {}
    end

    # All assoc_date arrays from ms_obj, each part, and within each part's ot_layer.
    def assoc_date_arrays(ms_json)
      arrays = [ms_json['assoc_date']]
      Array(ms_json['part']).each do |part|
        arrays << part['assoc_date']
        Array(part['ot_layer']).each do |layer|
          lr = layer['layer_record'] || {}
          arrays << lr['assoc_date']
          Array(lr['para']).each { |pa| arrays << pa['assoc_date'] }
        end
      end
      arrays
    end
end
