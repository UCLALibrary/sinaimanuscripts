# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_names_dates_places_metadata.html.erb', type: :view do
  def render_with(json)
    document = SolrDocument.new('id' => 'ndp-view', 'manuscript_json_ts' => json.to_json)
    render partial: 'catalog/work_record--sinai/names_dates_places_metadata', locals: { document: document }
  end

  # The grouped blocks NOP-176 introduced: one .part-grouped-block--sinai per entry,
  # holding the entry title plus that entry's own As Written / note lines.
  def section_items(heading)
    doc = Nokogiri::HTML.fragment(rendered)
    section = doc.css('section.ndp-section--sinai').find { |s| s.at_css('h2')&.text&.strip == heading }
    section ? section.css('div.ndp-item--sinai.part-grouped-block--sinai') : []
  end

  context 'with names, dates, and places' do
    let(:json) do
      {
        'assoc_name' => [
          { 'value' => 'Zaydan', 'role' => { 'id' => 'owner', 'label' => 'Owner' }, 'as_written' => 'زيدان', 'note' => ['Owner note'] },
          # A second entry with no As Written and no note: it still gets its own group.
          { 'value' => 'Ibrahim', 'role' => { 'id' => 'scribe', 'label' => 'Scribe' } }
        ],
        'part' => [
          {
            'label' => 'Part 1',
            'ot_layer' => [
              {
                'layer_record' => {
                  'state' => { 'id' => 'overtext', 'label' => 'Overtext' },
                  'assoc_date' => [
                    { 'value' => '913/914 CE', 'iso' => { 'not_before' => '0913' }, 'type' => { 'id' => 'origin', 'label' => 'Origin Date' } }
                  ]
                }
              }
            ]
          }
        ],
        'assoc_place' => [
          { 'value' => 'Cairo', 'event' => { 'id' => 'discovery', 'label' => 'Place of Discovery' } }
        ]
      }
    end

    before { render_with(json) }

    it 'renders the three section headings' do
      expect(rendered).to have_css('section.ndp-section--sinai h2.overview-heading--sinai', text: 'Names')
      expect(rendered).to have_css('section.ndp-section--sinai h2.overview-heading--sinai', text: 'Dates')
      expect(rendered).to have_css('section.ndp-section--sinai h2.overview-heading--sinai', text: 'Places')
    end

    it 'renders the concatenated item titles' do
      expect(rendered).to have_css('.ndp-item__title--sinai', text: 'Zaydan (Owner)')
      expect(rendered).to have_css('.ndp-item__title--sinai', text: '913/914 CE (Origin Date, Part 1)')
      expect(rendered).to have_css('.ndp-item__title--sinai', text: 'Cairo (Place of Discovery)')
    end

    it 'renders the As Written line with an isolated RTL value' do
      expect(rendered).to have_css('.ndp-item__line--sinai', text: 'As Written: زيدان')
      expect(rendered).to have_css('bdi.ndp-item__as-written-value--sinai', text: 'زيدان')
    end

    it 'renders note lines' do
      expect(rendered).to have_css('.ndp-item__line--sinai', text: 'Owner note')
    end

    # NOP-176: an entry and its sub-fields must share one grouped block, so the
    # block's 2px inner gap separates them while its 12px margin separates entries.
    it 'wraps each entry together with its own sub-fields in one grouped block' do
      items = section_items('Names') # ndp_sort orders names alphabetically: Ibrahim, then Zaydan

      expect(items.size).to eq(2)
      expect(items.last.text).to include('Zaydan (Owner)', 'As Written: زيدان', 'Owner note')
      expect(items.first.text).to include('Ibrahim (Scribe)')
      expect(items.first.text).not_to include('Owner note')
    end

    it 'gives a sub-field-less entry its own group so the 12px rhythm holds' do
      expect(section_items('Dates').size).to eq(1)
      expect(section_items('Places').size).to eq(1)
      expect(section_items('Places').first.css('.ndp-item__line--sinai')).to be_empty
    end

    # The 2px gap comes from the grouped block's flex gap, so the title and its
    # lines must be direct siblings — an intermediate wrapper would silently
    # restore the old flat spacing (it is what NOP-176 removed).
    it 'makes every child of an entry a title or a sub-field line' do
      children = section_items('Names').flat_map { |i| i.element_children.to_a }

      expect(children).not_to be_empty
      expect(children.map { |c| c['class'] }).to all(match(/ndp-item__(title|line)--sinai/))
    end
  end

  context 'when a group is empty' do
    before do
      render_with('assoc_name' => [{ 'value' => 'Zaydan', 'role' => { 'id' => 'owner', 'label' => 'Owner' } }])
    end

    it 'renders the populated section' do
      expect(rendered).to have_css('h2.overview-heading--sinai', text: 'Names')
    end

    it 'omits sections that have no entries' do
      expect(rendered).not_to have_css('h2.overview-heading--sinai', text: 'Dates')
      expect(rendered).not_to have_css('h2.overview-heading--sinai', text: 'Places')
    end
  end

  context 'with no associated data' do
    before { render_with({}) }

    it 'renders nothing' do
      expect(rendered.strip).to be_empty
    end
  end
end
