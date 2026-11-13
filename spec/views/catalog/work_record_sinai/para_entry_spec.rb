# frozen_string_literal: true

require 'rails_helper'

# NOP-189: _para_entry renders paracontent on the Full Description Paracontents
# section and the Guest Content tab. A para can carry several subtypes; all of
# them show, in data order.
RSpec.describe 'catalog/work_record--sinai/_para_entry.html.erb', type: :view do
  before do
    render partial: 'catalog/work_record--sinai/para_entry', locals: { pa: pa, data_path: 'ms_obj.para[0]' }
  end

  let(:page) { Capybara.string(rendered) }
  let(:types_row) do
    page.all('.work-field-row--sinai', visible: :all).find { |r| r.find('dt', visible: :all).text(:all) == 'Types' }
  end

  # Sinai Syriac 102, f. 1v
  context 'with no label and multiple subtypes' do
    let(:pa) do
      { 'locus' => 'f. 1v', 'lang' => [{ 'label' => 'Arabic' }],
        'subtype' => [{ 'label' => 'Waqf/Endowment' }, { 'label' => 'Anathema' }] }
    end

    it 'shows all subtypes in the header in place of a label' do
      expect(page).to have_css('.work-accordion__title--sinai', text: 'Waqf/Endowment, Anathema, f. 1v', exact_text: true)
    end

    it 'shows all subtypes in a Types row' do
      expect(types_row).to have_css('dd', text: 'Waqf/Endowment, Anathema', visible: :all)
    end

    it 'puts the Types row first, above Language' do
      labels = page.all('.work-field-label--sinai', visible: :all).map { |l| l.text(:all) }
      expect(labels).to eq(%w[Types Language])
    end
  end

  # Sinai Syriac 102, f. 190v
  context 'with a label and multiple subtypes' do
    let(:pa) do
      { 'label' => 'Commission note', 'locus' => 'f. 190v', 'lang' => [{ 'label' => 'Arabic' }],
        'subtype' => [{ 'label' => 'Commission' }, { 'label' => 'Supplication' }] }
    end

    it 'shows the label in the header' do
      expect(page).to have_css('.work-accordion__title--sinai', text: 'Commission note, f. 190v', exact_text: true)
    end

    it 'still lists the subtypes in a Types row' do
      expect(types_row).to have_css('dd', text: 'Commission, Supplication', visible: :all)
    end
  end

  context 'with no subtypes' do
    let(:pa) { { 'label' => 'Ownership note', 'locus' => 'f. 2r', 'lang' => [{ 'label' => 'Arabic' }] } }

    it 'renders no Types row' do
      expect(types_row).to be_nil
    end
  end

  context 'with subtypes and no other details' do
    let(:pa) { { 'locus' => 'f. 3r', 'subtype' => [{ 'label' => 'Commission' }] } }

    it 'renders an expandable accordion so the Types row is reachable' do
      expect(page).to have_css('details.work-accordion--sinai', visible: :all)
      expect(types_row).to have_css('dd', text: 'Commission', visible: :all)
    end
  end
end
