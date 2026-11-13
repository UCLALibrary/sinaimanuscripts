# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_items_metadata.html.erb', type: :view do
  # _items_metadata renders only ms_obj-level ot_layer text units (ones not attached
  # to a part). The regenerated tetst fixtures keep every layer under part[], so hoist
  # the part layers to the root to exercise this partial with real fixture data.
  def hoisted_document(fixture_name)
    ms_json = JSON.parse(File.read(Rails.root.join(ManuscriptFixtureHelper::EXPORT_TEST_PATH, "#{fixture_name}.json")))
    ms_json['ot_layer'] = Array(ms_json['part']).flat_map { |part| Array(part.delete('ot_layer')) }
    build_manuscript_document(fixture_name, 'manuscript_json_ts' => ms_json.to_json)
  end

  # Wraps work_wit entries in a single root-level text unit.
  def work_wit_document(work_wits)
    json = { 'ot_layer' => [{ 'layer_record' => { 'text_unit' => [
      { 'locus' => 'ff. 1r-9v', 'text_unit_record' => { 'work_wit' => work_wits } }
    ] } }] }
    SolrDocument.new('id' => 'work-wit-test', 'manuscript_json_ts' => json.to_json)
  end

  let(:document) { hoisted_document('tetst02') }

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

      it 'renders the work title from desc_title' do
        expect(rendered).to have_css('.work-accordion__title--sinai', text: /\ABook of Psalms, ff\. 1r-85v\z/)
      end

      it 'renders the Uniform Title as a works_ssim search link' do
        expect(rendered).to have_css('.work-field-label--sinai', text: 'Uniform Title', visible: :all)
        expect(rendered).to have_link('Psalms', href: '/catalog?f%5Bworks_ssim%5D%5B%5D=Psalms', visible: :all)
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
      # Note type labels are intentionally not rendered (see the inline-JSON Item Notes context below).
      it 'renders item notes without the type label' do
        expect(rendered).to have_css('.part-expandable__label--sinai', text: 'Item Notes', visible: :all)
        expect(rendered).to have_content('Peshitta version.')
        expect(rendered).not_to have_content('Other Notes')
      end
    end
  end

  context 'with tetst01 (multiple text units across parts)' do
    let(:document) { hoisted_document('tetst01') }

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

  # Item Notes and Editions detail (text_unit_record.note / .bib[type.id=edition]).
  # Built from inline JSON so the note/edition edge cases are controlled without
  # editing the solr/sinaiportal_data submodule fixtures.
  context 'with item notes and editions (inline JSON)' do
    let(:document) do
      json = {
        'ot_layer' => [
          { 'layer_record' => { 'text_unit' => [
            {
              'label' => 'Item A', 'locus' => 'ff. 1r-10v',
              'text_unit_record' => {
                'lang' => [{ 'label' => 'Greek' }],
                'note' => [
                  { 'type' => { 'label' => 'Foliation' }, 'value' => 'First note value.' },
                  { 'type' => { 'label' => 'Condition' }, 'value' => 'Second note value.' },
                  { 'value' => 'Untyped note value.' }
                ],
                'bib' => [
                  { 'type' => { 'id' => 'edition' }, 'citation' => 'Smith 1900', 'range' => 'pp. 10-20',
                    'note' => ['Edition note one.'] },
                  { 'type' => { 'id' => 'edition' }, 'citation' => 'Jones 1950' },
                  { 'type' => { 'id' => 'cite' }, 'citation' => 'Not an edition' }
                ]
              }
            }
          ] } }
        ]
      }
      SolrDocument.new('id' => 'notes-editions', 'manuscript_json_ts' => json.to_json)
    end

    it 'renders the item header with number, locus, and language' do
      expect(rendered).to have_css('h3.item-heading--sinai', text: 'Item 1, ff. 1r-10v (Greek)')
    end

    describe 'Item Notes' do
      it 'renders the Item Notes label' do
        expect(rendered).to have_css('.part-expandable__label--sinai', text: 'Item Notes', visible: :all)
      end

      it 'renders only the note value, without the type label' do
        expect(rendered).not_to have_css('.part-grouped-block__line--sinai strong')
        expect(rendered).not_to have_content('Foliation:')
        expect(rendered).not_to have_content('Condition:')
        expect(rendered).to have_content('First note value.')
        expect(rendered).to have_content('Second note value.')
      end

      it 'renders each note on its own line' do
        expect(rendered).to have_css('.part-grouped-block__line--sinai', text: /First note value\./, visible: :all)
        expect(rendered).to have_css('.part-grouped-block__line--sinai', text: /Second note value\./, visible: :all)
      end

      it 'renders an untyped note value without an orphaned colon' do
        expect(rendered).to have_content('Untyped note value.')
        expect(rendered).not_to have_content(': Untyped note value.')
      end
    end

    describe 'Editions' do
      it 'renders the Editions label' do
        expect(rendered).to have_css('.part-expandable__label--sinai', text: 'Editions', visible: :all)
      end

      it 'joins citation and range with a comma when range is present' do
        expect(rendered).to have_css('.part-grouped-block__line--sinai', text: 'Smith 1900, pp. 10-20', visible: :all)
      end

      it 'renders citation alone (no trailing comma) when range is absent' do
        expect(rendered).to have_css('.part-grouped-block__line--sinai', text: 'Jones 1950', visible: :all)
        expect(rendered).not_to have_content('Jones 1950,')
      end

      it 'renders edition notes on their own lines' do
        expect(rendered).to have_css('.part-grouped-block__note--sinai', text: 'Edition note one.', visible: :all)
      end

      it 'excludes non-edition bib entries' do
        expect(rendered).not_to have_content('Not an edition')
      end
    end
  end

  # NOP-190: desc_title on the title line; each linked work (work.id[]) gets a
  # Uniform Title link followed by its own reference numbers.
  context 'with a witness linked to two works (inline JSON)' do
    let(:document) do
      ww = {
        'locus' => 'ff. 2r-5v',
        'work' => {
          'desc_title' => 'Homily on Psalm 6',
          'refno' => [{ 'source' => 'CPG', 'idno' => '0000' }],
          'id' => [
            { 'ark' => 'ark:/21198/w1', 'pref_title' => 'Homilia in Psalmum 6',
              'refno' => [{ 'source' => 'CPG', 'idno' => '7751' }] },
            { 'ark' => 'ark:/21198/w2', 'pref_title' => 'Life of a saint',
              'refno' => [{ 'source' => 'BHG', 'idno' => '1234' }, { 'source' => 'CPG', 'idno' => '5678' }] }
          ]
        }
      }
      work_wit_document([ww])
    end

    it 'shows only desc_title and locus on the title line (no refnos)' do
      expect(rendered).to have_css('.work-accordion__title--sinai', text: /\AHomily on Psalm 6, ff\. 2r-5v\z/)
    end

    it 'renders one Uniform Title line per linked work, each followed by its refnos' do
      lines = Capybara.string(rendered).all('.work-uniform-title--sinai', visible: :all).map { |n| n.text(:all).strip }
      expect(lines).to eq(['Homilia in Psalmum 6 (CPG 7751)', 'Life of a saint (BHG 1234, CPG 5678)'])
    end

    it 'links only the title, not the reference numbers' do
      expect(rendered).to have_link('Homilia in Psalmum 6',
                                    href: '/catalog?f%5Bworks_ssim%5D%5B%5D=Homilia+in+Psalmum+6', visible: :all)
      expect(rendered).to have_link('Life of a saint',
                                    href: '/catalog?f%5Bworks_ssim%5D%5B%5D=Life+of+a+saint', visible: :all)
      link_texts = Capybara.string(rendered).all('.work-uniform-title--sinai a', visible: :all).map { |a| a.text(:all) }
      expect(link_texts).to eq(['Homilia in Psalmum 6', 'Life of a saint'])
    end

    it 'places Uniform Title as the first field of the expanded entry' do
      labels = Capybara.string(rendered).all('.work-field-label--sinai', visible: :all).map { |n| n.text(:all) }
      expect(labels.first).to eq('Uniform Title')
    end
  end

  context 'with contributors at both the work and linked-work level (inline JSON)' do
    let(:author) { { 'id' => 'ark:/21198/a1', 'agent_record' => { 'pref_name' => 'John Chrysostom' }, 'role' => { 'id' => 'author', 'label' => 'Author' } } }

    let(:document) do
      ww = {
        'work' => {
          'desc_title' => 'Homily',
          'creator' => [
            { 'id' => 'ark:/21198/a2', 'agent_record' => { 'pref_name' => 'Ephrem' }, 'role' => { 'id' => 'translator', 'label' => 'Translator' } },
            author
          ],
          'id' => [{
            'pref_title' => 'Homilia',
            'creator' => [
              author,
              { 'id' => 'ark:/21198/a1', 'agent_record' => { 'pref_name' => 'John Chrysostom' }, 'role' => { 'id' => 'attributed', 'label' => 'Attributed author' } }
            ]
          }]
        }
      }
      work_wit_document([ww])
    end

    let(:contributor_lines) do
      Capybara.string(rendered).all('.work-field-row--sinai', visible: :all)
              .find { |row| row.first('.work-field-label--sinai', visible: :all).text(:all) == 'Contributors' }
              .all('.work-field-value--sinai div', visible: :all).map { |n| n.text(:all).strip }
    end

    it 'merges both lists, drops exact agent+role duplicates, and keeps author → translator → rest order' do
      expect(contributor_lines).to eq([
                                        'John Chrysostom (Author)',
                                        'Ephrem (Translator)',
                                        'John Chrysostom (Attributed author)'
                                      ])
    end
  end

  context 'with a witness that has no linked works (inline JSON)' do
    let(:document) do
      work_wit_document([{ 'locus' => 'f. 10r', 'work' => { 'desc_title' => 'Unidentified liturgical text' } }])
    end

    it 'renders the desc_title as a static (non-expandable) title' do
      expect(rendered).to have_css('.work-accordion--static--sinai .work-accordion__title--sinai',
                                   text: 'Unidentified liturgical text, f. 10r')
    end

    it 'does not render a Uniform Title field' do
      expect(rendered).not_to have_css('.work-field-label--sinai', text: 'Uniform Title', visible: :all)
    end
  end

  context 'with a linked work but no desc_title (inline JSON)' do
    let(:document) do
      work_wit_document([{ 'work' => { 'id' => [{ 'pref_title' => 'Bible. Psalms' }] } }])
    end

    it 'shows Untitled rather than falling back to the uniform title' do
      expect(rendered).to have_css('.work-accordion__title--sinai', text: /\AUntitled\z/)
      expect(rendered).to have_link('Bible. Psalms', visible: :all)
    end
  end
end
