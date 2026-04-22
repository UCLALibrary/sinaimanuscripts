# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_item_overview_metadata.html.erb', type: :view do
  let(:document) { build_manuscript_document('tetst02') }
  let(:config) { CatalogController.blacklight_config }

  before do
    # Set up Blacklight context so show_presenter(document) works
    allow(view).to receive(:blacklight_config).and_return(config)
    allow(view).to receive(:search_state).and_return(
      Blacklight::SearchState.new({}, config, controller)
    )
    allow(view).to receive(:search_action_path).and_return('/catalog')
    allow(view).to receive(:should_render_field?).and_return(true)
    render partial: 'catalog/work_record--sinai/item_overview_metadata', locals: { document: document }
  end

  context 'with tetst02 (fully populated single-part manuscript)' do
    it 'renders Location from Solr repository/collection fields' do
      expect(rendered).to have_css('dt', text: 'Location')
      expect(rendered).to have_content("St. Catherine's Monastery")
      expect(rendered).to have_content('Old Collection')
    end

    it 'renders Current State from Solr state_ssi' do
      expect(rendered).to have_css('dt', text: 'Current State')
      expect(rendered).to have_content('Codex')
    end

    it 'renders Origin from JSON assoc_date' do
      expect(rendered).to have_css('dt', text: 'Origin')
      expect(rendered).to have_content('9th c. CE')
    end

    it 'renders Scripts from JSON writing data' do
      expect(rendered).to have_css('dt', text: 'Scripts')
      expect(rendered).to have_content('Serto (Syriac)')
    end

    it 'renders Languages from Solr ot_language_ssim' do
      expect(rendered).to have_css('dt', text: 'Languages')
      expect(rendered).to have_content('Syriac')
    end

    it 'renders Extent combining extent, dim, and weight with pipe separators' do
      expect(rendered).to have_css('dt', text: 'Extent')
      expect(rendered).to have_content('85 ff.')
      expect(rendered).to have_content('180 x 130 x 22.0 mm')
      expect(rendered).to have_content('312.4 g')
    end

    it 'renders Foliation from JSON fol and foliation notes' do
      expect(rendered).to have_css('dt', text: 'Foliation')
      expect(rendered).to have_content('ff. 1-85')
      expect(rendered).to have_content('Modern pencil foliation.')
    end

    it 'renders Collation from JSON coll and viscodex link' do
      expect(rendered).to have_css('dt', text: 'Collation')
      expect(rendered).to have_content('Quire 1: 1x8')
      expect(rendered).to have_link('Visualization of Sinai Syriac 799',
                                     href: 'https://vceditor.library.upenn.edu/project/test789/viewOnly')
    end
  end

  context 'with empty manuscript JSON and no Solr fields' do
    let(:document) { SolrDocument.new('id' => 'empty', 'manuscript_json_ts' => '{}') }

    it 'renders no data rows' do
      expect(rendered).not_to have_css('dt')
    end
  end

  context 'with partial data (extent only, no origin)' do
    let(:document) do
      json = { 'extent' => '50 ff.', 'part' => [] }
      SolrDocument.new('id' => 'partial', 'manuscript_json_ts' => json.to_json)
    end

    it 'renders Extent but not Origin' do
      expect(rendered).to have_css('dt', text: 'Extent')
      expect(rendered).not_to have_css('dt', text: 'Origin')
    end
  end
end
