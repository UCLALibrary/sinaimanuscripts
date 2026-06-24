# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IndexResultsHelper, type: :helper do
  describe 'sinai_index_origin_dates' do
    def doc_with(json)
      SolrDocument.new('id' => '8', 'manuscript_json_ts' => json.to_json)
    end

    it 'returns [] when there is no manuscript_json_ts' do
      expect(helper.sinai_index_origin_dates(SolrDocument.new('id' => '8'))).to eq []
    end

    it 'returns [] for malformed JSON' do
      doc = SolrDocument.new('id' => '8', 'manuscript_json_ts' => '{ not json')
      expect(helper.sinai_index_origin_dates(doc)).to eq []
    end

    it 'collects an origin date at the ms_obj level' do
      doc = doc_with('assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '9th c. CE' }])
      expect(helper.sinai_index_origin_dates(doc)).to eq ['9th c. CE']
    end

    it 'collects an origin date at the part level' do
      doc = doc_with('part' => [{ 'assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '10th c. CE' }] }])
      expect(helper.sinai_index_origin_dates(doc)).to eq ['10th c. CE']
    end

    it 'collects an origin date within a part ot_layer (layer_record and its para)' do
      doc = doc_with(
        'part' => [{
          'ot_layer' => [{
            'layer_record' => {
              'assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '11th c. CE' }],
              'para' => [{ 'assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '1306 CE' }] }]
            }
          }]
        }]
      )
      expect(helper.sinai_index_origin_dates(doc)).to eq ['11th c. CE', '1306 CE']
    end

    it 'collects from all three levels and dedupes repeated values' do
      doc = doc_with(
        'assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '9th c. CE' }],
        'part' => [{
          'assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '9th c. CE' }],
          'ot_layer' => [{
            'layer_record' => { 'assoc_date' => [{ 'type' => { 'id' => 'origin' }, 'value' => '10th c. CE' }] }
          }]
        }]
      )
      expect(helper.sinai_index_origin_dates(doc)).to eq ['9th c. CE', '10th c. CE']
    end

    it 'excludes non-origin dates and blank values' do
      doc = doc_with(
        'assoc_date' => [
          { 'type' => { 'id' => 'acquisition' }, 'value' => '1900 CE' },
          { 'type' => { 'id' => 'origin' }, 'value' => '' },
          { 'type' => { 'id' => 'origin' }, 'value' => '8th c. CE' }
        ]
      )
      expect(helper.sinai_index_origin_dates(doc)).to eq ['8th c. CE']
    end
  end
end
