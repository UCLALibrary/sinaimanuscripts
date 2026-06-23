# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_undertexts_metadata.html.erb', type: :view do
  before do
    render partial: 'catalog/work_record--sinai/undertexts_metadata', locals: { document: document }
  end

  let(:document) { SolrDocument.new('id' => 'ark:/21198/test', 'manuscript_json_ts' => manuscript_json.to_json) }

  context 'when root-level UTOs reuse the same uto_layer_ark as Part UTOs (tetst01 shape)' do
    # Root and Part UTOs are distinct layers; sharing a layer ark must NOT cause
    # the root UTOs to be deduped out of the flyleaves section.
    let(:manuscript_json) do
      {
        'part' => [
          {
            'label' => 'Part 1',
            'uto' => [
              { 'uto_layer_ark' => 'ark:/21198/p1ul1', 'label' => 'Greek Undertext: Psalms' },
              { 'uto_layer_ark' => 'ark:/21198/p1ul2', 'label' => 'Syriac Undertext: Liturgy' }
            ]
          }
        ],
        'uto' => [
          { 'uto_layer_ark' => 'ark:/21198/p1ul1', 'label' => 'Greek Undertext: Psalms' },
          { 'uto_layer_ark' => 'ark:/21198/p1ul2', 'label' => 'Syriac Undertext: Liturgy' }
        ]
      }
    end

    it 'renders the Part group heading and the flyleaves heading' do
      expect(rendered).to have_css('h3.undertext-group__label--sinai', text: 'Part 1')
      expect(rendered).to have_css('h3.undertext-group__label--sinai', text: 'In flyleaves, bindings, repairs')
    end

    it 'renders all four UTO entries (2 in the Part, 2 in flyleaves)' do
      expect(rendered).to have_css('article.undertext-entry--sinai', count: 4)
    end
  end

  context 'when a root-level UTO has a uto_ms_ark' do
    let(:manuscript_json) do
      { 'uto' => [{ 'uto_ms_ark' => 'ark:/21198/z1rs2q6s', 'label' => 'CPA Undertext: Matthew' }] }
    end

    it 'links the title to the UTO ms_object catalog page' do
      expect(rendered).to have_link('CPA Undertext: Matthew', href: '/catalog/ark:%2F21198%2Fz1rs2q6s')
    end
  end

  context 'when a root-level UTO has no uto_ms_ark' do
    let(:manuscript_json) do
      { 'uto' => [{ 'uto_layer_ark' => 'ark:/21198/p1ul1', 'label' => 'Greek Undertext: Psalms' }] }
    end

    it 'renders the title as plain text rather than a link' do
      expect(rendered).to have_css('span.undertext-entry__title--plain--sinai', text: 'Greek Undertext: Psalms')
      expect(rendered).to have_no_link('Greek Undertext: Psalms')
    end
  end

  context 'with no UTOs at all' do
    let(:manuscript_json) { {} }

    it 'renders nothing' do
      expect(rendered.strip).to be_empty
    end
  end
end
