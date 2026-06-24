# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_guest_content_metadata.html.erb', type: :view do
  # Self-contained manuscript JSON exercising every branch of the Guest Content tab:
  # a root-level guest layer (with all layer fields, an item, and in-layer paracontent),
  # a part-level guest layer, plus guest-typed paracontent and notes outside any layer.
  let(:ms_json) do
    {
      'ark' => 'ark:/test/guest01',
      'shelfmark' => 'Test Guest 01',
      'guest_layer' => [
        {
          'label' => 'Guest Content (Naskh)',
          'locus' => 'Front Board Inside',
          'layer_record' => {
            'summary' => 'A later guest note added inside the front board.',
            'extent' => '1 f.',
            'dim' => '120 x 90 mm',
            'assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '13th c. CE' }],
            'assoc_place' => [{ 'event' => { 'id' => 'origin' }, 'value' => 'Sinai' }],
            'assoc_name' => [
              { 'role' => { 'id' => 'scribe' }, 'agent_record' => { 'pref_name' => 'A later hand' } }
            ],
            'writing' => [
              { 'locus' => 'f. 1', 'script' => [{ 'label' => 'Naskh', 'writing_system' => 'Arabic' }], 'note' => ['cursive hand'] }
            ],
            'ink' => [{ 'color' => ['brown'] }],
            'layout' => [{ 'columns' => '1', 'lines' => '12', 'dim' => '100 x 70 mm' }],
            'text_unit' => [
              {
                'locus' => 'Front Board Inside',
                'text_unit_record' => {
                  'summary' => 'Unidentified text concerning Sundays.',
                  'lang' => [{ 'label' => 'Arabic' }],
                  'work_wit' => [{ 'work' => { 'pref_title' => 'Unidentified text' } }]
                }
              }
            ],
            'para' => [
              {
                'type' => { 'id' => 'history' },
                'label' => 'Ownership inscription',
                'locus' => 'f. 1v',
                'lang' => [{ 'label' => 'Arabic' }],
                'as_written' => 'Owner statement'
              }
            ]
          }
        }
      ],
      'part' => [
        {
          'label' => 'Part 1',
          'guest_layer' => [
            { 'label' => 'Part guest layer', 'layer_record' => { 'summary' => 'Part-level guest content.' } }
          ],
          'note' => [{ 'type' => { 'id' => 'guest' }, 'value' => 'Part-level guest note.' }]
        }
      ],
      'para' => [
        { 'type' => { 'id' => 'guest' }, 'label' => 'Guest marginal note', 'locus' => 'f. 5r', 'as_written' => 'Margin text' }
      ],
      'note' => [
        { 'type' => { 'id' => 'guest' }, 'value' => 'A guest note outside any guest layer.' }
      ]
    }
  end

  let(:document) { SolrDocument.new('id' => 'guest01', 'manuscript_json_ts' => ms_json.to_json) }

  before do
    render partial: 'catalog/work_record--sinai/guest_content_metadata', locals: { document: document }
  end

  context 'with guest content present' do
    it 'renders one section per guest layer (root + part)' do
      expect(rendered).to have_css('div.guest-content-section--sinai', count: 2)
    end

    it 'renders the guest layer header with label and locus' do
      expect(rendered).to have_css('h3.part-heading--sinai', text: 'Guest Content (Naskh), Front Board Inside')
    end

    it 'renders the guest layer summary in italics' do
      expect(rendered).to have_css('p.part-summary--sinai', text: /later guest note added inside the front board/)
    end

    it 'renders Origin with a conditional semicolon between date and place' do
      expect(rendered).to have_css('dt', text: 'Origin')
      expect(rendered).to have_content('13th c. CE ; Sinai')
    end

    it 'renders Extent with a pipe separator' do
      expect(rendered).to have_css('dt', text: 'Extent')
      expect(rendered).to have_content('1 f. | 120 x 90 mm')
    end

    it 'renders the shared layer fields (Scribe / Writing / Ink / Layout)' do
      expect(rendered).to have_css('dt', text: 'Scribe')
      expect(rendered).to have_content('A later hand')
      expect(rendered).to have_css('dt', text: 'Writing')
      expect(rendered).to have_content('Naskh (Arabic)')
      expect(rendered).to have_css('dt', text: 'Ink')
      expect(rendered).to have_content('brown')
      expect(rendered).to have_css('dt', text: 'Layout')
      expect(rendered).to have_content('Columns: 1')
      expect(rendered).to have_content('Lines: 12')
    end

    it 'renders items within the guest layer via the shared item_entry partial' do
      expect(rendered).to have_css('h3.item-heading--sinai', text: /Item 1/)
      expect(rendered).to have_content('(Arabic)')
      expect(rendered).to have_content('Unidentified text concerning Sundays.')
    end

    it 'renders in-layer paracontent' do
      expect(rendered).to have_css('.works-section__label--sinai', text: 'Paracontents')
      expect(rendered).to have_css('.work-accordion__title--sinai', text: 'Ownership inscription, f. 1v')
    end

    it 'renders the part-level guest layer summary' do
      expect(rendered).to have_css('h3.part-heading--sinai', text: 'Part guest layer')
      expect(rendered).to have_content('Part-level guest content.')
    end

    it 'renders guest paracontent outside a guest layer' do
      expect(rendered).to have_css('h2#section-guest-paracontent', text: 'Guest Paracontent')
      expect(rendered).to have_css('.work-accordion__title--sinai', text: 'Guest marginal note, f. 5r')
    end

    it 'renders guest notes outside a guest layer (root and part)' do
      expect(rendered).to have_css('h2#section-guest-notes', text: 'Guest Notes')
      expect(rendered).to have_content('A guest note outside any guest layer.')
      expect(rendered).to have_content('Part-level guest note.')
    end
  end

  context 'with no guest content' do
    let(:document) { SolrDocument.new('id' => 'empty', 'manuscript_json_ts' => '{}') }

    it 'renders nothing' do
      expect(rendered.strip).to be_empty
    end
  end
end
