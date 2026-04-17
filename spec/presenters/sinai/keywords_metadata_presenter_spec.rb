# frozen_string_literal: true
require 'rails_helper'
require 'support/solr_doc_double'

include SolrDocDouble

RSpec.describe Sinai::KeywordsMetadataPresenter do
  let(:solr_doc) do
    doc_double_with_fields_to_render(
      'features_ssim' => 'Features',
      'ot_genre_ssim' => 'Genre'
    )
  end
  let(:solr_doc_missing_items) do
    doc_double_with_fields_to_render(
      'features_ssim' => 'Features'
    )
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:presenter_object_missing_items) { described_class.new(document: solr_doc_missing_items) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata-sinai/keywords_metadata.yml'))) }

  context 'with a solr document containing keywords metadata' do
    describe '#terms' do
      it 'returns the Features Key' do
        expect(config['features_ssim'].to_s).to eq('Features')
      end

      it 'returns the Genre Key' do
        expect(config['ot_genre_ssim'].to_s).to eq('Genre')
      end
    end

    describe "#keywords_terms terms" do
      let(:all) { presenter_object.keywords_terms.keys.length }
      let(:missing) { presenter_object_missing_items.keywords_terms.keys.length }

      it "returns existing keys" do
        expect(all).to eq 2
        expect(config.length).to eq all
      end

      it "is missing elements" do
        expect(all - missing).to_not eq 0
        expect(config.length - missing).to_not eq 0
      end
    end
  end
end
