# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_items_metadata.html.erb', type: :view do
  let(:document) { build_manuscript_document('tetst02') }

  before do
    render partial: 'catalog/work_record--sinai/items_metadata', locals: { document: document }
  end

  context 'with tetst02 (single text unit with work and rubric)' do
    it 'renders the Contents heading' do
      expect(rendered).to have_css('h2', text: 'Contents')
    end

    it 'renders the item header with number, locus, and language' do
      expect(rendered).to have_css('h3.item-heading--sinai', text: /Item 1/)
      expect(rendered).to have_css('h3.item-heading--sinai', text: /ff\. 1r-85v/)
      expect(rendered).to have_css('h3.item-heading--sinai', text: /Syriac/)
    end

    it 'renders the item summary' do
      expect(rendered).to have_css('p.item-summary--sinai', text: /complete Psalter/)
    end

    describe 'Works sub-section' do
      it 'renders the Works label' do
        expect(rendered).to have_css('.works-section__label--sinai', text: 'Works')
      end

      it 'renders the work title from pref_title' do
        expect(rendered).to have_css('.work-accordion__title--sinai', text: /Psalms/)
      end

      it 'renders work locus' do
        expect(rendered).to have_css('.work-accordion__title--sinai', text: /ff\. 1r-85v/)
      end

      it 'renders as an expandable accordion (has details)' do
        expect(rendered).to have_css('details.work-accordion--sinai')
      end

      # Content inside <details> is hidden by default — use visible: :all
      it 'renders Variant Title in expanded view' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'Variant Title', visible: :all)
        expect(rendered).to have_content('Dawid')
      end

      it 'renders As Written in expanded view' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'As Written', visible: :all)
      end

      it 'renders Table of Contents entries' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'Table of Contents', visible: :all)
        expect(rendered).to have_content('Psalms 1')
        expect(rendered).to have_content('Psalms 51')
        expect(rendered).to have_content('Psalms 101')
      end

      it 'renders Excerpts with incipit and explicit' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'Excerpts', visible: :all)
        expect(rendered).to have_css('.work-excerpt__header--sinai', text: /Incipit/, visible: :all)
        expect(rendered).to have_css('.work-excerpt__header--sinai', text: /Explicit/, visible: :all)
      end

      it 'renders excerpt translations' do
        expect(rendered).to have_css('.work-excerpt__translation--sinai', text: /Blessed is the man/, visible: :all)
      end

      it 'renders Witness Notes' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'Witness Notes', visible: :all)
        expect(rendered).to have_content('Peshitta version')
      end
    end

    describe 'Rubrics sub-section' do
      it 'renders the Rubrics label' do
        expect(rendered).to have_css('.works-section__label--sinai', text: 'Rubrics, Etc.')
      end

      it 'renders rubric header with subtype and locus' do
        expect(rendered).to have_css('.work-accordion__title--sinai', text: /Rubric/)
        expect(rendered).to have_css('.work-accordion__title--sinai', text: /f\. 1r/)
      end

      # Content inside rubric <details> — use visible: :all
      it 'renders Language in expanded rubric' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'Language', visible: :all)
      end

      it 'renders As Written in expanded rubric' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'As Written', visible: :all)
      end

      it 'renders Translation in expanded rubric' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'Translation', visible: :all)
        expect(rendered).to have_content('The Book of Praises')
      end
    end

    describe 'Item Notes' do
      it 'renders item notes with type label' do
        expect(rendered).to have_content('Other Notes')
        expect(rendered).to have_content('Peshitta version.')
      end
    end
  end

  context 'with tetst01 (multiple text units across parts)' do
    let(:document) { build_manuscript_document('tetst01') }

    it 'renders multiple items' do
      expect(rendered).to have_css('.item-block--sinai', minimum: 2)
    end

    it 'numbers items sequentially across parts' do
      expect(rendered).to have_css('h3.item-heading--sinai', text: /Item 1/)
      expect(rendered).to have_css('h3.item-heading--sinai', text: /Item 2/)
    end
  end

  context 'with empty manuscript JSON' do
    let(:document) { SolrDocument.new('id' => 'empty', 'manuscript_json_ts' => '{}') }

    it 'renders nothing' do
      expect(rendered.strip).to be_empty
    end
  end

  context 'with no text_units in parts' do
    let(:document) do
      json = { 'part' => [{ 'label' => 'Part 1', 'ot_layer' => [{ 'layer_record' => {} }] }] }
      SolrDocument.new('id' => 'no-tu', 'manuscript_json_ts' => json.to_json)
    end

    it 'renders nothing when text_units are absent' do
      expect(rendered.strip).to be_empty
    end
  end
end
