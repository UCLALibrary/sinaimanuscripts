# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'facets' do
    before do
      allow(Flipflop).to receive(:sinai?).and_return(true)
    end

    let(:facets_sinai) do
      controller
        .blacklight_config
        .facet_fields.keys
        .map { |field| field.gsub(/\_s+im$/, '') }
    end

    let(:expected_facets) do
      ["generic_type",
       "genre",
       "human_readable_language",
       "human_readable_resource_type",
       "location",
       "member_of_collections",
       "named_subject",
       "subject",
       "year_isim"]
    end

    it 'has exactly expected facets' do
      pending("Need to update for Sinai Manuscripts site.")
      expect(facets_sinai).to contain_exactly(*expected_facets)
    end
  end

  describe "show fields" do
    let(:show_fields) do
      controller
        .blacklight_config
        .show_fields.keys
    end
    let(:expected_show_fields) do
      ["architect_tesim", "alternative_title_tesim", "ark_ssi", "author_tesim",
       "based_near_label_tesim", "binding_note_ssi", "calligrapher_tesim", "caption_tesim",
       "collation_tesim", "colophon_tesim", "composer_tesim", "condition_note_ssi", "contents_note_tesim",
       "contributor_tesim", "creator_tesim", "date_created_tesim", "description_tesim",
       "dimensions_tesim", "dlcs_collection_name_tesim", "editor_tesim",
       "engraver_tesim", "explicit_tesim", "extent_tesim", "features_tesim", "finding_aid_url_ssm",
       "foliation_tesim", "format_tesim", "funding_note_tesim", "genre_tesim", "geographic_coordinates_ssim",
       "human_readable_resource_type_tesim", "human_readable_rights_statement_tesim", "human_readable_language_tesim",
       "identifier_tesim", "illuminator_tesim", "illustrator_tesim", "iiif_manifest_url_ssi",
       "illustrations_note_tesim", "incipit_tesim", "inscription_tesim",
       "keyword_tesim", "latitude_tesim", "local_rights_statement_ssim", "location_tesim", "local_identifier_ssm",
       "longitude_tesim", "lyricist_tesim", "medium_tesim", "member_of_collections_ssim",
       "named_subject_tesim", "note_tesim", "oclc_ssi", "opac_url_ssi", "page_layout_ssim", "photographer_tesim",
       "place_of_origin_tesim", "printmaker_tesim", "provenance_tesim", "publisher_tesim",
       "repository_tesim", "rights_country_tesim", "rights_holder_tesim", "rubricator_tesim",
       "scribe_tesim", "script_tesim", "services_contact_ssm", "subject_tesim", "subject_topic_tesim",
       "summary_tesim", "support_tesim", "title_tesim", "toc_tesim", "uniform_title_tesim",
       "hand_note_tesim", "writing_system_tesim", "commentator_tesim", "translator_tesim",
       "license_tesim", "normalized_date_sim", "subject_geographic_tesim", "subject_temporal_tesim",
       "associated_name_tesim", "descriptive_title_tesim", "form_ssi", "references_tesim", "shelfmark_ssi", "other_versions_tesim"]
    end

    it 'has exactly expected show fields' do
      pending("Need to update for Sinai Manuscripts site.")
      expect(show_fields).to contain_exactly(*expected_show_fields)
    end
  end

  describe "sort fields" do
    let(:sort_fields) do
      controller
        .blacklight_config
        .sort_fields.keys
    end

    let(:expected_sort_fields) do
      ["score desc", "title_alpha_numeric_ssort asc", "title_alpha_numeric_ssort desc", "date_dtsort desc", "date_dtsort asc"]
    end

    it 'has exactly expected sort fields' do
      pending("Need to update for Sinai Manuscripts site.")
      expect(sort_fields).to contain_exactly(*expected_sort_fields)
    end
  end

  describe 'index fields' do
    let(:index_fields) do
      controller
        .blacklight_config
        .index_fields.keys
        .map { |field| field.gsub(/\_s+im$/, '') }
    end

    let(:expected_index_fields) do
      ['description_tesim',
       'date_created_tesim',
       'human_readable_resource_type_tesim',
       'photographer_tesim',
       'member_of_collections']
    end

    it 'has exactly the expected index fields' do
      pending("Need to update for Sinai Manuscripts site.")
      expect(index_fields).to contain_exactly(*expected_index_fields)
    end
  end

  describe 'search fields' do
    let(:search_fields) { controller.blacklight_config.search_fields.keys }

    let(:expected_search_fields) do
      ['all_fields', 'subject_tesim', 'title_tesim']
    end

    it 'has exactly the expected search fields' do
      pending("Need to update for Sinai Manuscripts site.")
      expect(search_fields).to contain_exactly(*expected_search_fields)
    end
  end

  describe "show action" do
    render_views

    before do
      allow(controller).to receive(:enforce_show_permissions).and_return(true)
      allow(controller).to receive(:search_service).and_return(search_service)
      allow(search_service).to receive(:fetch).and_return([mock_response, mock_document])
    end
    let(:ark) { 'ark:/123/abc' }
    let(:mock_response) { instance_double(Blacklight::Solr::Response) }
    let(:mock_document) { SolrDocument.new(id: ark, export_formats: {}) }
    let(:search_service) { instance_double(Blacklight::SearchService) }

    it 'Renders a blank SolrDocument (meaning missing fields don\'t cause errors)' do
      get :show, params: { id: ark }
    end

    xit "has collection count on Collection Item record page" do
      # get :show, params: { id: ark }
      # expect(assigns[:document]).not_to be_nil
    end
  end
end
