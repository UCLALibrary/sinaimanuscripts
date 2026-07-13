# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_names_dates_places_metadata.html.erb', type: :view do
  def render_with(json)
    document = SolrDocument.new('id' => 'ndp-view', 'manuscript_json_ts' => json.to_json)
    render partial: 'catalog/work_record--sinai/names_dates_places_metadata', locals: { document: document }
  end

  context 'with names, dates, and places' do
    let(:json) do
      {
        'assoc_name' => [
          { 'value' => 'Zaydan', 'role' => { 'id' => 'owner', 'label' => 'Owner' }, 'as_written' => 'زيدان', 'note' => ['Owner note'] }
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
