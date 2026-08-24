# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'facets' do
    before do
      allow(Flipflop).to receive(:sinai?).and_return(true)
    end

    let(:facet_keys) { controller.blacklight_config.facet_fields.keys }

    it 'has the expected facets' do
      expected_facets = %w[
        ms_type_ssi
        state_ssi
        features_ssim
        support_ssim
        repository_ssim
        collection_ssim
        names_ssim
        places_ssim
        date_types_ssim
        ot_script_ssim
        ot_writing_system_ssim
        ot_genre_ssim
        ot_year_isim
        ot_language_ssim
        ot_works_ssim
        para_script_ssim
        para_writing_system_ssim
        para_genre_ssim
        para_year_isim
        para_language_ssim
        para_works_ssim
        para_type_ssim
        para_names_ssim
        uto_script_ssim
        uto_year_isim
        uto_language_ssim
        generic_type_sim
      ]
      expect(facet_keys).to contain_exactly(*expected_facets)
    end

    it 'expands the Object Type facet on load' do
      expect(controller.blacklight_config.facet_fields['ms_type_ssi'].collapse).to be false
    end

    it 'groups the guest/paracontent facets in display order' do
      expect(controller.blacklight_config.facet_field_names('guest')).to eq(
        %w[
          para_type_ssim
          para_script_ssim
          para_writing_system_ssim
          para_language_ssim
          para_year_isim
          para_names_ssim
          para_works_ssim
          para_genre_ssim
        ]
      )
    end

    it 'groups the undertext facets in display order' do
      expect(controller.blacklight_config.facet_field_names('undertext')).to eq(
        %w[uto_script_ssim uto_language_ssim uto_year_isim]
      )
    end
  end

  describe 'index fields' do
    let(:index_fields) { controller.blacklight_config.index_fields.keys }

    let(:expected_index_fields) do
      %w[
        shelfmark_ssi
        extent_tesi
        ms_type_ssi
        text_unit_labels_tesim
        ot_date_tesim
        ot_language_ssim
        repository_ssim
        collection_ssim
      ]
    end

    it 'has exactly the expected index fields' do
      expect(index_fields).to contain_exactly(*expected_index_fields)
    end
  end

  describe 'sort fields' do
    let(:sort_fields) { controller.blacklight_config.sort_fields.keys }

    let(:expected_sort_fields) do
      [
        'score desc',
        'shelfmark_tsort asc',
        'shelfmark_tsort desc',
        'date_dtsort desc',
        'date_dtsort asc',
        'last_modified_dtsi desc',
        'last_modified_dtsi asc'
      ]
    end

    it 'has exactly expected sort fields' do
      expect(sort_fields).to contain_exactly(*expected_sort_fields)
    end
  end

  describe 'search fields' do
    let(:search_fields) { controller.blacklight_config.search_fields.keys }

    let(:expected_search_fields) do
      %w[
        full_text_tesim
        shelfmark_tsi
        titles_tesim
        names_tesim
        exerpts_tesim
        places_tesim
        contents_tesim
        paracontent_tesim
      ]
    end

    it 'has exactly the expected search fields' do
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
  end
end
