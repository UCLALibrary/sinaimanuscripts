# frozen_string_literal: true
require 'rails_helper'
require 'support/solr_doc_double'

include SolrDocDouble

RSpec.describe Sinai::OverviewMetadataPresenter do
  let(:solr_doc) do
    doc_double_with_fields_to_render(
      'repository_ssim' => 'Location',
      'collection_ssim' => 'Collection',
      'state_ssi' => 'Current State',
      'place_of_origin_tesim' => 'Origin',
      'ot_date_tesim' => 'Date of Origin',
      'ot_script_ssim' => 'Scripts',
      'ot_language_ssim' => 'Languages',
      'extent_tesi' => 'Extent',
      'format_extent_tesim' => 'Extent',
      'foliation_tesim' => 'Foliation',
      'collation_tesim' => 'Collation'
    )
  end
  let(:solr_doc_missing_items) do
    doc_double_with_fields_to_render(
      'repository_ssim' => 'Location',
      'place_of_origin_tesim' => 'Origin',
      'ot_date_tesim' => 'Date of Origin'
    )
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:presenter_object_missing_items) { described_class.new(document: solr_doc_missing_items) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata-sinai/overview_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe '#terms' do
      it 'returns the Location Key' do
        expect(config['repository_ssim'].to_s).to eq('Location')
      end

      it 'returns the Collection Key' do
        expect(config['collection_ssim'].to_s).to eq('Collection')
      end

      it 'returns the Current State Key' do
        expect(config['state_ssi'].to_s).to eq('Current State')
      end

      it 'returns the Origin Key' do
        expect(config['place_of_origin_tesim'].to_s).to eq('Origin')
      end

      it 'returns the Date of Origin Key' do
        expect(config['ot_date_tesim'].to_s).to eq('Date of Origin')
      end

      it 'returns the Scripts Key' do
        expect(config['ot_script_ssim'].to_s).to eq('Scripts')
      end

      it 'returns the Languages Key' do
        expect(config['ot_language_ssim'].to_s).to eq('Languages')
      end

      it 'returns the Extent Key' do
        expect(config['extent_tesi'].to_s).to eq('Extent')
      end

      it 'returns the Foliation Key' do
        expect(config['foliation_tesim'].to_s).to eq('Foliation')
      end

      it 'returns the Collation Key' do
        expect(config['collation_tesim'].to_s).to eq('Collation')
      end
    end

    describe "#overview_terms terms" do
      let(:all) { presenter_object.overview_terms.keys.length }
      let(:missing) { presenter_object_missing_items.overview_terms.keys.length }

      it "returns existing keys" do
        expect(all).to eq 11
        expect(config.length).to eq all
      end

      it "is missing elements" do
        expect(all - missing).to_not eq 0
        expect(config.length - missing).to_not eq 0
      end
    end
  end
end
