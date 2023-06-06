# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Sinai::ContentsWorksMetadataPresenter do
  let(:solr_doc) do
    {
      'descriptive_title_tesim' => 'Descriptive title',
      'uniform_title_tesim' => 'Uniform title'
    }
  end
  let(:solr_doc_missing_items) do
    {
      'descriptive_title_tesim' => 'Descriptive title'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:presenter_object_missing_items) { described_class.new(document: solr_doc_missing_items) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata-sinai/contents_works_metadata.yml'))) }

  context 'with a solr document containing contents metadata' do
    describe '#terms' do
      it 'returns the Descriptive title Key' do
        expect(config['descriptive_title_tesim'].to_s).to eq('Descriptive title')
      end

      it 'returns the Uniform title Key' do
        expect(config['uniform_title_tesim'].to_s).to eq('Uniform title')
      end
    end

    describe "#contents_terms terms" do
      let(:all) { presenter_object.contents_terms.keys.length }
      let(:missing) { presenter_object_missing_items.contents_terms.keys.length }

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
