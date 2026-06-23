# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_content_metadata.html.erb', type: :view do
  let(:document) { build_manuscript_document('tetst02') }

  before do
    render partial: 'catalog/work_record--sinai/content_metadata', locals: { document: document }
  end

  context 'with tetst02 (single-part manuscript)' do
    it 'renders the top-level part header with label, date, and locus' do
      expect(rendered).to have_css('h2.contents-part-heading--sinai', text: /Part 1/)
      expect(rendered).to have_css('h2.contents-part-heading--sinai', text: /9th c\. CE/)
      expect(rendered).to have_css('h2.contents-part-heading--sinai', text: /ff\. 1-85/)
    end

    it 'renders the part summary in italics' do
      expect(rendered).to have_css('p.part-summary--sinai', text: /Syriac Psalter/)
    end

    it 'renders the part container' do
      expect(rendered).to have_css('div.contents-part--sinai')
    end

    describe 'Items (reuse the shared _item_entry partial)' do
      it 'renders the item header with number, locus, and language' do
        expect(rendered).to have_css('h3.item-heading--sinai', text: /Item 1/)
        expect(rendered).to have_css('h3.item-heading--sinai', text: /ff\. 1r-85v/)
        expect(rendered).to have_css('h3.item-heading--sinai', text: /Syriac/)
      end

      it 'renders the Works sub-section with the work title' do
        expect(rendered).to have_css('.works-section__label--sinai', text: 'Works')
        expect(rendered).to have_css('.work-accordion__title--sinai', text: /Psalms/)
      end
    end
  end

  context 'with tetst01 (multi-part manuscript)' do
    let(:document) { build_manuscript_document('tetst01') }

    it 'renders a top-level part header for each part' do
      expect(rendered).to have_css('h2.contents-part-heading--sinai', minimum: 2)
      expect(rendered).to have_css('h2.contents-part-heading--sinai', text: /Part 1/)
      expect(rendered).to have_css('h2.contents-part-heading--sinai', text: /Part 2/)
    end
  end

  context 'with a part that has no origin date or locus' do
    let(:document) do
      SolrDocument.new(
        'id' => 'no-date',
        'manuscript_json_ts' => { 'part' => [{ 'label' => 'Part 1' }] }.to_json
      )
    end

    it 'renders the bare label with no orphaned punctuation or parentheses' do
      expect(rendered).to have_css('h2.contents-part-heading--sinai', text: 'Part 1')
      expect(rendered).not_to have_css('h2.contents-part-heading--sinai', text: /[(,]/)
    end
  end

  context 'with empty manuscript JSON' do
    let(:document) { SolrDocument.new('id' => 'empty', 'manuscript_json_ts' => '{}') }

    it 'renders nothing' do
      expect(rendered.strip).to be_empty
    end
  end
end
