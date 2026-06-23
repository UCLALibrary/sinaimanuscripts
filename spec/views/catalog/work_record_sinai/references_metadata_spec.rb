# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_references_and_bibliography_metadata.html.erb', type: :view do
  before do
    render partial: 'catalog/work_record--sinai/references_and_bibliography_metadata', locals: { document: document }
  end

  let(:document) { SolrDocument.new('id' => 'ark:/21198/test', 'manuscript_json_ts' => manuscript_json.to_json) }

  context 'when bib entries are nested below the root level' do
    # bib[] uses Dawn's `..bib[]` deep-descendant notation: entries can live at the
    # root and at any nested layer / text_unit / work_wit level. They must all render.
    let(:manuscript_json) do
      {
        'bib' => [
          { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Gardthausen 1886', 'range' => 'p. 198',
            'note' => ['Root-level reference note'] }
        ],
        'part' => [
          {
            'ot_layer' => [
              {
                'layer_record' => {
                  'text_unit' => [
                    {
                      'text_unit_record' => {
                        'bib' => [
                          { 'type' => { 'id' => 'cite' }, 'shortcode' => 'Kashouh 2012', 'range' => 'pp. 120-145',
                            'note' => ['Nested citation note'] }
                        ],
                        'work_wit' => [
                          {
                            'bib' => [
                              { 'type' => { 'id' => 'edition' }, 'shortcode' => 'Müller-Kessler 1998',
                                'note' => ['Nested edition note'] }
                            ]
                          }
                        ]
                      }
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
    end

    it 'renders the root-level reference' do
      expect(rendered).to have_css('dt.related-mss-group__row-label--sinai', text: 'References')
      expect(rendered).to include('Gardthausen 1886, p. 198')
    end

    it 'renders the citation collected from the nested text_unit level' do
      expect(rendered).to have_css('dt.related-mss-group__row-label--sinai', text: 'Citations')
      expect(rendered).to include('Kashouh 2012, pp. 120-145')
    end

    it 'renders the edition collected from the nested work_wit level' do
      expect(rendered).to have_css('dt.related-mss-group__row-label--sinai', text: 'Editions')
      expect(rendered).to include('Müller-Kessler 1998')
    end

    it 'indents notes in every section, not just References' do
      indented = 'div.references-bibliography__note--indented--sinai'
      expect(rendered).to have_css(indented, text: 'Root-level reference note')
      expect(rendered).to have_css(indented, text: 'Nested citation note')
      expect(rendered).to have_css(indented, text: 'Nested edition note')
    end
  end

  context 'with no bibliography at all' do
    let(:manuscript_json) { {} }

    it 'renders no bibliography section rows' do
      expect(rendered).to have_no_css('dt.related-mss-group__row-label--sinai', text: 'References')
      expect(rendered).to have_no_css('dt.related-mss-group__row-label--sinai', text: 'Citations')
    end
  end
end
