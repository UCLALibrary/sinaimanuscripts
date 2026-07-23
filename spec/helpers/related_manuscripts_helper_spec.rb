# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatedManuscriptsHelper, type: :helper do
  before { delete_all_documents_from_solr }

  describe '#manuscripts_including_in_reconstruction' do
    subject(:included) { helper.manuscripts_including_in_reconstruction(ark) }

    let(:ark) { 'ark:/21198/z1dv21gp' }

    let(:manuscript_reconstruction) do
      { id: 'ark:/21198/z1manuscr', ms_type_ssi: 'Manuscript',
        shelfmark_ssi: 'Sinai Arabic 999', reconstructed_from_ssim: [ark] }
    end

    let(:uto_reconstruction) do
      { id: 'ark:/21198/z1utoreco', ms_type_ssi: 'Undertext Object',
        shelfmark_ssi: 'UTO Sinai Arabic 999', reconstructed_from_ssim: [ark] }
    end

    def index(*docs)
      solr = Blacklight.default_index.connection
      solr.add(docs)
      solr.commit
    end

    context 'with both a manuscript and a UTO reconstruction' do
      before { index(manuscript_reconstruction, uto_reconstruction) }

      it 'returns the manuscript reconstruction' do
        expect(included).to contain_exactly(
          id: 'ark:/21198/z1manuscr', shelfmark: 'Sinai Arabic 999'
        )
      end

      it 'excludes UTO reconstructions (NOP-153)' do
        expect(included.map { |r| r[:id] }).not_to include('ark:/21198/z1utoreco')
      end
    end

    context 'when the only reconstructions are UTOs (as on z1dv21gp)' do
      before { index(uto_reconstruction) }

      it 'returns nothing' do
        expect(included).to be_empty
      end
    end

    context 'when the ark is blank' do
      let(:ark) { '' }

      it 'returns an empty array' do
        expect(included).to eq([])
      end
    end
  end

  describe '#related_mss_entries' do
    subject(:entries) { helper.related_mss_entries(ms_json) }

    let(:root_entry) { { 'type' => { 'id' => 'filiation' }, 'label' => 'Root filiation' } }
    let(:part_entry) { { 'type' => { 'id' => 'disjecta' }, 'label' => 'Part disjecta' } }

    context 'with related_mss only inside a part (as on z1dv21gp)' do
      let(:ms_json) { { 'related_mss' => nil, 'part' => [{ 'related_mss' => [part_entry] }] } }

      it 'surfaces the part-level entry' do
        expect(entries).to eq([part_entry])
      end
    end

    context 'with entries at both the manuscript level and parts' do
      let(:ms_json) do
        { 'related_mss' => [root_entry],
          'part' => [{ 'related_mss' => [part_entry] }, { 'label' => 'no related mss' }] }
      end

      it 'concatenates root and part entries without deduping' do
        expect(entries).to eq([root_entry, part_entry])
      end
    end

    context 'with no related_mss anywhere' do
      let(:ms_json) { { 'part' => [{ 'label' => 'Part 1' }] } }

      it 'returns an empty array' do
        expect(entries).to eq([])
      end
    end
  end
end
