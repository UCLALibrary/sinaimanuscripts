# frozen_string_literal: true
require 'rails_helper'
require 'support/solr_doc_double'

include SolrDocDouble

RSpec.describe Ursus::TaglineMetadataPresenter do
  let(:solr_doc) do
    doc_double_with_fields_to_render(
      'ark_ssi' => 'test',
      'title_tesim' => 'Test record',
      'repository_tesim' => 'Test Repository'
    )
  end

  let(:solr_doc_with_shelfmark) do
    doc_double_with_fields_to_render(
      'ark_ssi' => 'test',
      'title_tesim' => 'Test record',
      'repository_tesim' => 'Test Repository',
      'shelfmark_ssi' => 'Arabic NF 8'
    )
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:presenter_object_with_shelfmark) { described_class.new(document: solr_doc_with_shelfmark) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/tagline_metadata.yml'))) }

  describe 'config' do
    it 'returns the Shelfmark Key' do
      expect(config['shelfmark_ssi'].to_s).to eq('Shelfmark')
    end
  end

  describe "#tagline_terms" do
    it "returns shelfmark" do
      expect(presenter_object_with_shelfmark.tagline_terms).to be_instance_of(Hash)
      expect(presenter_object_with_shelfmark.tagline_terms.keys.length).to eq 1
    end

    it "does not return shelfmark when missing" do
      expect(presenter_object.tagline_terms.keys.length).to eq 0
    end
  end
end
