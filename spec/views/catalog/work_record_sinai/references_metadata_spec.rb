# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_references_and_bibliography_metadata.html.erb', type: :view do
  before do
    render partial: 'catalog/work_record--sinai/references_and_bibliography_metadata', locals: { document: document }
  end

  let(:document) { SolrDocument.new('id' => 'ark:/21198/test', 'manuscript_json_ts' => manuscript_json.to_json) }

  # The grouped blocks that NOP-174 introduced: one .part-grouped-block--sinai per
  # entry, holding the entry line plus that entry's own notes.
  def section_groups(label)
    doc = Nokogiri::HTML.fragment(rendered)
    row = doc.css('div.related-mss-group__row--sinai').find { |r| r.at_css('dt')&.text&.strip == label }
    row ? row.css('dd > div.part-grouped-block--sinai') : []
  end

  context 'when bib entries are nested below the root level' do
    # bib[] uses Dawn's `..bib[]` deep-descendant notation: entries can live at the
    # root and at any nested layer / text_unit / work_wit level. They must all render.
    let(:manuscript_json) do
      {
        'ark' => 'ark:/21198/test',
        'shelfmark' => 'Sinai Test 1',
        'iiif' => [
          { 'manifest' => 'https://example.org/iiif/1', 'label' => 'Manifest one' },
          { 'manifest' => 'https://example.org/iiif/2', 'label' => 'Manifest two' }
        ],
        'viscodex' => [{ 'url' => 'https://example.org/viscodex/1', 'label' => 'VisCodex model' }],
        'bib' => [
          { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Gardthausen 1886', 'range' => 'p. 198',
            'note' => ['Root-level reference note'] },
          # A second entry with no note of its own: it still gets its own group.
          { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Kamil', 'range' => '[35], p. 58' }
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

    # NOP-174: an entry and its notes must share one grouped block, so the block's
    # 2px inner gap separates them while its 12px margin separates whole entries.
    it 'wraps each entry together with its own notes in one grouped block' do
      groups = section_groups('References')

      expect(groups.size).to eq(2)
      expect(groups.first.text).to include('Gardthausen 1886, p. 198', 'Root-level reference note')
      expect(groups.last.text).to include('Kamil, [35], p. 58')
      expect(groups.last.text).not_to include('Root-level reference note')
    end

    it 'groups the single-entry sections too' do
      expect(section_groups('Citations').size).to eq(1)
      expect(section_groups('Editions').size).to eq(1)
      expect(section_groups('Citations').first.text).to include('Kashouh 2012, pp. 120-145', 'Nested citation note')
    end

    # The dd carries no flex gap of its own (see _si-metadata-block.scss), so any
    # value line left outside a grouped block would collapse against its neighbour.
    it 'makes every value-column child a grouped block' do
      children = Nokogiri::HTML.fragment(rendered).css('dd.related-mss-group__row-value--sinai > *')

      expect(children).not_to be_empty
      expect(children.map { |c| c['class'] }).to all(include('part-grouped-block--sinai'))
    end

    it 'gives each note-less link line its own group so the lists keep their 12px rhythm' do
      expect(section_groups('IIIF Manifests').size).to eq(2)
      expect(section_groups('VisCodex').size).to eq(1)
      expect(section_groups('JSON Record').size).to eq(1)
      expect(section_groups('Item ARK').size).to eq(1)
      expect(section_groups('Data Portal').size).to eq(1)
    end

    # NOP-179: the raw-JSON dump left Full Description; the record's JSON is now a
    # link here, styled and behaving like the tab's other external links.
    describe 'JSON Record row' do
      let(:json_link) { section_groups('JSON Record').first&.at_css('a') }

      it 'links "View/download <shelfmark> data" to the manuscript_json endpoint' do
        expect(json_link.text.squish).to eq('View/download Sinai Test 1 data')
        expect(json_link['href']).to eq(manuscript_json_path('ark:/21198/test'))
        expect(json_link['href']).to eq('/catalog/ark:%2F21198%2Ftest/manuscript_json')
      end

      it 'opens in a new tab with the external-link icon, like the other external links' do
        expect(json_link['target']).to eq('_blank')
        expect(json_link['rel']).to eq('noopener')
        expect(json_link['class']).to eq('references-bibliography__link--sinai')
        expect(json_link.at_css('svg.references-bibliography__icon--sinai')).to be_present
      end

      it 'sits directly above VisCodex' do
        labels = Nokogiri::HTML.fragment(rendered).css('dt.related-mss-group__row-label--sinai').map { |dt| dt.text.strip }
        expect(labels.index('VisCodex')).to eq(labels.index('JSON Record') + 1)
      end
    end

    it 'leaves the VisCodex label to the shared uppercase label style (VISCODEX)' do
      dt = Nokogiri::HTML.fragment(rendered).css('dt').find { |d| d.text.strip == 'VisCodex' }
      expect(dt['class']).to eq('related-mss-group__row-label--sinai')
    end
  end

  # NOP-187: the same bib entry can sit at more than one level (ms_obj and a layer);
  # exact repeats render once, while entries differing in any field stay separate.
  context 'when bib entries repeat across levels' do
    let(:lewis) { { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Lewis 1894', 'range' => 'pp. 1-2' } }
    let(:manuscript_json) do
      {
        'bib' => [
          lewis,
          { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Kamil 1970', 'range' => 'p. 58' },
          { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Géhin 2017', 'range' => 'p. 10' }
        ],
        'part' => [
          { 'ot_layer' => [{ 'layer_record' => { 'bib' => [
            lewis.dup,
            { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Lewis 1894', 'range' => 'pp. 5-6' },
            { 'type' => { 'id' => 'ref' }, 'shortcode' => 'Kamil 1970', 'range' => 'p. 58',
              'note' => ['Layer-level note'] }
          ] } }] }
        ]
      }
    end

    def reference_lines
      section_groups('References').map { |g| g.text.squish }
    end

    it 'renders an exact repeat once' do
      expect(reference_lines.count { |l| l.include?('Lewis 1894, pp. 1-2') }).to eq(1)
    end

    it 'keeps the same source with different pages as separate entries' do
      expect(reference_lines.count { |l| l.include?('Lewis 1894, pp. 5-6') }).to eq(1)
      expect(reference_lines.count { |l| l.include?('Lewis 1894') }).to eq(2)
    end

    it 'keeps the same source and pages as separate entries when only one has a note' do
      kamil = reference_lines.select { |l| l.include?('Kamil 1970, p. 58') }
      expect(kamil.size).to eq(2)
      expect(kamil.count { |l| l.include?('Layer-level note') }).to eq(1)
    end

    it 'renders every remaining entry' do
      expect(section_groups('References').size).to eq(5)
    end
  end

  context 'with no bibliography at all' do
    let(:manuscript_json) { {} }

    it 'renders no bibliography section rows' do
      expect(rendered).to have_no_css('dt.related-mss-group__row-label--sinai', text: 'References')
      expect(rendered).to have_no_css('dt.related-mss-group__row-label--sinai', text: 'Citations')
    end

    it 'renders no JSON Record row for an empty record' do
      expect(rendered).to have_no_css('dt.related-mss-group__row-label--sinai', text: 'JSON Record')
    end
  end

  context 'when the record has no shelfmark' do
    let(:manuscript_json) { { 'ark' => 'ark:/21198/test' } }

    it 'drops the shelfmark from the JSON Record link text' do
      expect(section_groups('JSON Record').first.at_css('a').text.squish).to eq('View/download data')
    end
  end
end
