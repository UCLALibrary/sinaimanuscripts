# frozen_string_literal: true

module ManuscriptFixtureHelper
  EXPORT_TEST_PATH = 'solr/sinaiportal_data/export_test/merged'

  # Builds a SolrDocument from a JSON file in the sinaiportal export_test directory.
  # Uses the real test data files directly so that when upstream data changes,
  # tests catch any rendering breakage immediately.
  #
  # Usage: build_manuscript_document('tetst02') # loads tetst02.json
  def build_manuscript_document(fixture_name, solr_overrides = {})
    json_path = Rails.root.join(EXPORT_TEST_PATH, "#{fixture_name}.json")
    json_string = File.read(json_path)
    ms_json = JSON.parse(json_string)

    # Derive standard Solr fields from the JSON data
    solr_fields = {
      'id' => ms_json['ark'],
      'title_tesim' => [ms_json['shelfmark']],
      'shelfmark_ssi' => ms_json['shelfmark'],
      'has_model_ssim' => ['Work'],
      'manuscript_json_ts' => json_string,
      'state_ssi' => ms_json.dig('state', 'label'),
      'features_ssim' => Array(ms_json['features']).map { |f| f['label'] },
    }

    # Location fields
    location = Array(ms_json['location']).first
    if location
      solr_fields['repository_ssim'] = [location['repository']].compact
      solr_fields['collection_ssim'] = [location['collection']].compact
    end

    # Language/script from ot_layers
    ot_languages = []
    ot_scripts = []
    Array(ms_json['part']).each do |part|
      Array(part['ot_layer']).each do |layer|
        lr = layer['layer_record'] || {}
        Array(lr['writing']).each do |w|
          Array(w['script']).each do |s|
            ot_scripts << s['label']
            ot_languages << s['writing_system'] if s['writing_system']
          end
        end
      end
    end
    solr_fields['ot_language_ssim'] = ot_languages.uniq if ot_languages.any?
    solr_fields['ot_script_ssim'] = ot_scripts.uniq if ot_scripts.any?

    SolrDocument.new(solr_fields.merge(solr_overrides))
  end
end

RSpec.configure do |config|
  config.include ManuscriptFixtureHelper
end
