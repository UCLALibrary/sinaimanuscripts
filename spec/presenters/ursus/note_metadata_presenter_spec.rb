# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Ursus::NoteMetadataPresenter do
  let(:solr_doc) do
    {
      'caption_tesim' => 'Caption',
      'summary_tesim' => 'Summary',
      'description_tesim' => 'Description',
      'provenance_tesim' => 'Provenance',
      'contents_note_tesim' => 'Contents note',
      'colophon_tesim' => 'Colophon',
      'incipit_tesim' => 'Incipit',
      'explicit_tesim' => 'Explicit',
      'note_tesim' => 'Note'
    }
  end
  let(:solr_doc_missing_items) do
    {
      'caption_tesim' => 'Caption',
      'summary_tesim' => 'Summary',
      'description_tesim' => 'Description'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:presenter_object_missing_items) { described_class.new(document: solr_doc_missing_items) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/note_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe 'config' do
      it 'returns the Caption Key' do
        expect(config['caption_tesim'].to_s).to eq('Caption')
      end

      it 'returns the Summary Key' do
        expect(config['summary_tesim'].to_s).to eq('Summary')
      end

      it 'returns the Description Key' do
        expect(config['description_tesim'].to_s).to eq('Description')
      end

      it 'returns the Provenance Key' do
        expect(config['provenance_tesim'].to_s).to eq('Provenance')
      end

      it 'returns the Contents note Key' do
        expect(config['contents_note_tesim'].to_s).to eq('Contents note')
      end

      it 'returns the Colophon Key' do
        expect(config['colophon_tesim'].to_s).to eq('Colophon')
      end

      it 'returns the Incipit Key' do
        expect(config['incipit_tesim'].to_s).to eq('Incipit')
      end

      it 'returns the Explicit Key' do
        expect(config['explicit_tesim'].to_s).to eq('Explicit')
      end

      it 'returns the Note Key' do
        expect(config['note_tesim'].to_s).to eq('Note')
      end
    end

    describe "#note terms" do
      let(:all) { presenter_object.note_terms.keys.length }
      let(:missing) { presenter_object_missing_items.note_terms.keys.length }

      it "returns existing keys" do
        expect(presenter_object.note_terms).to be_instance_of(Hash)
        expect(all).to eq 9
        expect(config.length).to eq all
      end

      it "is missing some elements" do
        expect(all - missing).to_not eq 0
        expect(config.length - missing).to_not eq 0
      end
    end
  end
end
