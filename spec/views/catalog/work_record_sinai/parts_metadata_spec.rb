# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_parts_metadata.html.erb', type: :view do
  let(:document) { build_manuscript_document('tetst02') }

  before do
    render partial: 'catalog/work_record--sinai/parts_metadata', locals: { document: document }
  end

  context 'with tetst02 (single-part manuscript)' do
    it 'renders the part heading with label, date, and locus' do
      expect(rendered).to have_css('h3.part-heading--sinai', text: /Part 1/)
      expect(rendered).to have_css('h3.part-heading--sinai', text: /9th c\. CE/)
      expect(rendered).to have_css('h3.part-heading--sinai', text: /ff\. 1-85/)
    end

    it 'renders the part summary' do
      expect(rendered).to have_css('p.part-summary--sinai', text: /Syriac Psalter in Serto script/)
    end

    it 'renders Origin from assoc_date' do
      expect(rendered).to have_css('dt', text: 'Origin')
      expect(rendered).to have_content('9th c. CE')
    end

    it 'renders Extent with pipe separator' do
      expect(rendered).to have_css('dt', text: 'Extent')
      expect(rendered).to have_content('85 ff. | 170 x 120 mm')
    end

    it 'renders Support as expandable with label and note' do
      expect(rendered).to have_css('details.part-expandable--sinai')
      expect(rendered).to have_css('dt', text: 'Support')
      expect(rendered).to have_content('Parchment')
      expect(rendered).to have_content('Good quality parchment throughout.')
    end

    it 'renders Scribe' do
      expect(rendered).to have_css('dt', text: 'Scribe')
      expect(rendered).to have_content('Unknown scribe')
    end

    it 'renders Writing as expandable with script summary' do
      expect(rendered).to have_css('dt', text: 'Writing')
      expect(rendered).to have_content('Serto (Syriac)')
    end

    it 'renders Ink as expandable with color summary' do
      expect(rendered).to have_css('dt', text: 'Ink')
      expect(rendered).to have_content('black')
      expect(rendered).to have_content('red')
    end

    it 'renders Layout with columns, lines, and dimensions' do
      expect(rendered).to have_css('dt', text: 'Layout')
      expect(rendered).to have_content('Columns: 1')
      expect(rendered).to have_content('Lines: 18')
      expect(rendered).to have_content('Writing area: 150 x 100 mm')
    end
  end

  context 'with tetst01 (multi-part manuscript)' do
    let(:document) { build_manuscript_document('tetst01') }

    it 'renders multiple part sections' do
      expect(rendered).to have_css('div.part-section--sinai', minimum: 2)
    end

    it 'renders Part 1 and Part 2 headings' do
      expect(rendered).to have_css('h3.part-heading--sinai', text: /Part 1/)
      expect(rendered).to have_css('h3.part-heading--sinai', text: /Part 2/)
    end
  end

  context 'with empty manuscript JSON' do
    let(:document) { SolrDocument.new('id' => 'empty', 'manuscript_json_ts' => '{}') }

    it 'renders nothing' do
      expect(rendered.strip).to be_empty
    end
  end
end
