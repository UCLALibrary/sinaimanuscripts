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
        works_ssim
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

    it 'registers works_ssim as a hidden Works facet (label only, for Uniform Title links)' do
      works = controller.blacklight_config.facet_fields['works_ssim']
      expect(works.label).to eq('Works')
      expect(works.if).to be false
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

  # NOP-179: the "JSON Record" link on References & Bibliography.
  describe 'manuscript_json action' do
    before do
      allow(controller).to receive(:enforce_show_permissions).and_return(true)
      allow(controller).to receive(:search_service).and_return(search_service)
      allow(search_service).to receive(:fetch).and_return([mock_response, mock_document])
    end
    let(:ark) { 'ark:/21198/test' }
    # Stored minified, as the indexer writes it.
    let(:blob) { '{"ark":"ark:/21198/test","shelfmark":"Sinai Test 1"}' }
    let(:mock_response) { instance_double(Blacklight::Solr::Response) }
    let(:mock_document) { SolrDocument.new(id: ark, shelfmark_ssi: 'Sinai Test 1', manuscript_json_ts: blob) }
    let(:search_service) { instance_double(Blacklight::SearchService) }

    it 'serves the stored JSON pretty-printed, inline, named after the shelfmark' do
      get :manuscript_json, params: { id: ark }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('application/json')
      expect(response.body).to eq("{\n  \"ark\": \"ark:/21198/test\",\n  \"shelfmark\": \"Sinai Test 1\"\n}")
      expect(response.headers['Content-Disposition']).to start_with('inline')
      expect(response.headers['Content-Disposition']).to include('filename="Sinai Test 1.json"')
    end

    it 'sends an unparseable blob as stored rather than failing' do
      allow(search_service).to receive(:fetch)
        .and_return([mock_response, SolrDocument.new(id: ark, manuscript_json_ts: '{not json')])
      get :manuscript_json, params: { id: ark }

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('{not json')
    end

    it 'falls back to the ARK segment for the filename when there is no shelfmark' do
      allow(search_service).to receive(:fetch)
        .and_return([mock_response, SolrDocument.new(id: ark, manuscript_json_ts: blob)])
      get :manuscript_json, params: { id: ark }

      expect(response.headers['Content-Disposition']).to include('filename="test.json"')
    end

    it 'checks show permissions like the item page does' do
      get :manuscript_json, params: { id: ark }

      expect(controller).to have_received(:enforce_show_permissions)
    end

    it 'is a 404 when the record has no manuscript JSON' do
      allow(search_service).to receive(:fetch).and_return([mock_response, SolrDocument.new(id: ark)])
      get :manuscript_json, params: { id: ark }

      expect(response).to have_http_status(:not_found)
    end
  end
end
