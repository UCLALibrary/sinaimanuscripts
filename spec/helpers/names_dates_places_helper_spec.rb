# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NamesDatesPlacesHelper, type: :helper do
  # A hand-built blob exercising every aggregation rule: root / paracontent /
  # part-overtext-layer / text-unit paracontent / guest-layer sources, the
  # pref_name-then-value fallback, the origin-date Part label, the Guest Content
  # flag, locus-from-paracontent, as_written, notes, and sorting.
  let(:manuscript_json) do
    {
      'ark' => 'test:ndp',
      'shelfmark' => 'Test NDP',
      # root level
      'assoc_name' => [
        { 'value' => 'Zaydan', 'role' => { 'id' => 'owner', 'label' => 'Owner' } },
        { 'role' => { 'id' => 'unknown', 'label' => 'Unknown' } } # no name -> skipped
      ],
      'assoc_date' => [
        # origin, but NOT within a part overtext layer -> no Part label
        { 'value' => '800 CE', 'iso' => { 'not_before' => '0800' }, 'type' => { 'id' => 'origin', 'label' => 'Origin Date' } }
      ],
      'assoc_place' => [
        { 'value' => 'Amid' }, # no event -> no parenthetical
        { 'value' => 'Cairo', 'event' => { 'id' => 'discovery', 'label' => 'Place of Discovery' } }
      ],
      # root paracontent -> locus inherited
      'para' => [
        {
          'locus' => 'f. 1r',
          'assoc_name' => [
            {
              'agent_record' => { 'pref_name' => 'Andrew of Crete' },
              'value' => 'ignored fallback',
              'role' => { 'id' => 'annotator', 'label' => 'Annotator' },
              'as_written' => 'ܕܫܢܬܐ',
              'note' => ['Annotated in the margin']
            }
          ]
        }
      ],
      'part' => [
        {
          'label' => 'Part 1',
          'ot_layer' => [
            {
              'layer_record' => {
                'state' => { 'id' => 'overtext', 'label' => 'Overtext' },
                # origin date directly on the overtext layer -> Part 1, no locus
                'assoc_date' => [
                  { 'value' => '913/914 CE', 'iso' => { 'not_before' => '0913' }, 'type' => { 'id' => 'origin', 'label' => 'Origin Date' } }
                ],
                'text_unit' => [
                  {
                    'text_unit_record' => {
                      'para' => [
                        {
                          'locus' => 'f. 55r',
                          'assoc_date' => [
                            {
                              'value' => '1292 CE',
                              'iso' => { 'not_before' => '1292' },
                              'type' => { 'id' => 'origin', 'label' => 'Origin Date' },
                              'as_written' => 'ܠܐܦ̈ܝ',
                              'note' => ['AM 6,104 = 1292 CE']
                            }
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
      ],
      # root guest layer -> Guest Content flag
      'guest_layer' => [
        {
          'layer_record' => {
            'state' => { 'id' => 'guest', 'label' => 'Guest Content' },
            'assoc_name' => [
              { 'agent_record' => { 'pref_name' => 'Ephrem the Syrian' }, 'role' => { 'id' => 'reader', 'label' => 'Reader' } }
            ],
            'assoc_place' => [
              { 'place_record' => { 'pref_name' => 'Nisibis' }, 'event' => { 'id' => 'reading', 'label' => 'Place of Reading' } }
            ]
          }
        }
      ]
    }
  end

  let(:document) { SolrDocument.new('id' => 'test:ndp', 'manuscript_json_ts' => manuscript_json.to_json) }
  let(:result) { helper.names_dates_places_for(document) }

  describe 'names' do
    subject(:displays) { result[:names].map { |n| n[:display] } }

    it 'aggregates from root, paracontent, and guest layers, sorted alphabetically by display name' do
      expected = [
        'Andrew of Crete (Annotator), f. 1r',
        'Ephrem the Syrian (Reader, Guest Content)',
        'Zaydan (Owner)'
      ]
      expect(displays).to eq(expected)
    end

    it 'prefers agent_record.pref_name over value' do
      expect(displays.first).to start_with('Andrew of Crete')
      expect(displays.join).not_to include('ignored fallback')
    end

    it 'skips names with neither pref_name nor value' do
      expect(result[:names].size).to eq(3)
    end

    it 'carries as_written and notes' do
      andrew = result[:names].first
      expect(andrew[:as_written]).to eq('ܕܫܢܬܐ')
      expect(andrew[:notes]).to eq(['Annotated in the margin'])
    end
  end

  describe 'dates' do
    subject(:displays) { result[:dates].map { |d| d[:display] } }

    it 'sorts chronologically by iso.not_before' do
      expected = [
        '800 CE (Origin Date)',
        '913/914 CE (Origin Date, Part 1)',
        '1292 CE (Origin Date, Part 1), f. 55r'
      ]
      expect(displays).to eq(expected)
    end

    it 'shows the Part label only for origin dates within a part overtext layer' do
      expect(displays[0]).not_to include('Part') # root origin, not in ot_layer
      expect(displays[1]).to include('Part 1') # ot_layer direct
      expect(displays[2]).to include('Part 1') # ot_layer via text_unit paracontent
    end

    it 'takes locus only from the parent paracontent' do
      expect(displays[1]).not_to include('f. ') # direct on layer, no para
      expect(displays[2]).to end_with('f. 55r')
    end

    it 'carries as_written and notes on the paracontent date' do
      dated = result[:dates].last
      expect(dated[:as_written]).to eq('ܠܐܦ̈ܝ')
      expect(dated[:notes]).to eq(['AM 6,104 = 1292 CE'])
    end
  end

  describe 'places' do
    subject(:displays) { result[:places].map { |p| p[:display] } }

    it 'aggregates and sorts alphabetically, appending Guest Content within a guest layer' do
      expected = [
        'Amid',
        'Cairo (Place of Discovery)',
        'Nisibis (Place of Reading, Guest Content)'
      ]
      expect(displays).to eq(expected)
    end

    it 'omits the parenthetical entirely when there is no event' do
      expect(displays.first).to eq('Amid')
    end
  end

  describe 'graceful handling' do
    it 'produces no orphaned separators or empty parentheses' do
      all = result.values.flatten.map { |e| e[:display] }
      expect(all).to all(satisfy { |d| !d.include?('()') && !d.match?(/,\s*$/) && !d.start_with?(',') })
    end

    it 'returns empty groups for a blank blob' do
      empty = SolrDocument.new('id' => 'empty', 'manuscript_json_ts' => '{}')
      expect(helper.names_dates_places_for(empty)).to eq(names: [], dates: [], places: [])
    end

    it 'returns empty groups for malformed JSON' do
      bad = SolrDocument.new('id' => 'bad', 'manuscript_json_ts' => 'not json{')
      expect(helper.names_dates_places_for(bad).values.all?(&:empty?)).to be(true)
    end
  end

  describe 'layer deduplication' do
    # The merged blob denormalises a guest layer to both the root and its owning
    # part (same layer_record ark), so its associations must be counted once.
    let(:denormalized_json) do
      guest_layer = {
        'layer_record' => {
          'ark' => 'ark:/21198/dupGL',
          'state' => { 'id' => 'guest', 'label' => 'Guest Content' },
          'assoc_name' => [
            { 'value' => 'Guest Annotator', 'role' => { 'id' => 'annotator', 'label' => 'Annotator' } }
          ]
        }
      }
      {
        'guest_layer' => [guest_layer],
        'part' => [{ 'label' => 'Part 2', 'guest_layer' => [guest_layer] }]
      }
    end

    let(:document) { SolrDocument.new('id' => 'dup', 'manuscript_json_ts' => denormalized_json.to_json) }

    it 'aggregates a layer reachable via two paths only once' do
      names = helper.names_dates_places_for(document)[:names]
      expect(names.map { |n| n[:display] }).to eq(['Guest Annotator (Annotator, Guest Content)'])
    end
  end
end
