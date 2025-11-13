# frozen_string_literal: true
require 'rails_helper'
require 'support/solr_doc_double'

include SolrDocDouble

RSpec.describe Sinai::CodicologyMetadataPresenter do
  let(:solr_doc) do
    doc_double_with_fields_to_render(
      'format_extent_tesim' => 'Extent',
      'folio_dimensions_ss' => 'Typical Folio Dimensions',
      'collation_tesim' => 'Collation',
      'form_tesim' => 'Form',
      'support_tesim' => 'Support',
      'writing_system_tesim' => 'Writing system',
      'scribe_tesim' => 'Scribe',
      'script_tesim' => 'Script',
      'script_note_tesim' => 'Script Note',
      'ink_color_tesim' => 'Ink Color',
      'page_layout_ssim' => 'Page Layout',
      'foliation_tesim' => 'Foliation',
      'hand_note_tesim' => 'Hand Note',
      'binding_note_tesim' => 'Binding Note',
      'condition_note_tesim' => 'Condition Note',
      'description_tesim' => 'Physical Description note',
      'binding_condition_tesim' => 'Binding condition'
    )
  end
  let(:solr_doc_missing_items) do
    doc_double_with_fields_to_render
      'format_extent_tesim' => 'Extent',
      'collation_tesim' => 'Collation',
      'form_sim' => 'Form',
      'support_tesim' => 'Support',
      'writing_system_tesim' => 'Writing system',
      'script_tesim' => 'Script'
    )
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:presenter_object_missing_items) { described_class.new(document: solr_doc_missing_items) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata-sinai/codicology_metadata.yml'))) }

  context 'with a solr document containing codicology metadata' do
    describe '#terms' do
      it 'returns the Extent Key' do
        expect(config['format_extent_tesim'].to_s).to eq('Extent')
      end

      it 'returns the Collation Key' do
        expect(config['collation_tesim'].to_s).to eq('Collation')
      end

      it 'returns the Form Key' do
        expect(config['form_tesim'].to_s).to eq('Form')
      end

      it 'returns the Support Key' do
        expect(config['support_tesim'].to_s).to eq('Support')
      end

      it 'returns the Writing system Key' do
        expect(config['writing_system_tesim'].to_s).to eq('Writing system')
      end

      it 'returns the Scribe Key' do
        expect(config['scribe_tesim'].to_s).to eq('Scribe')
      end

      it 'returns the Script Key' do
        expect(config['script_tesim'].to_s).to eq('Script')
      end

      it 'returns the Page layout Key' do
        expect(config['page_layout_ssim'].to_s).to eq('Page Layout')
      end

      it 'returns the Foliation Key' do
        expect(config['foliation_tesim'].to_s).to eq('Foliation')
      end

      it 'returns the Hand note Key' do
        expect(config['hand_note_tesim'].to_s).to eq('Hand Note')
      end

      it 'returns the Binding note Key' do
        expect(config['binding_note_tesim'].to_s).to eq('Binding Note')
      end

      it 'returns the Condition note Key' do
        expect(config['condition_note_tesim'].to_s).to eq('Condition Note')
      end

      it 'returns the Physical Description note Key' do
        expect(config['description_tesim'].to_s).to eq('Physical Description note')
      end
    end

    describe "#codicology_terms terms" do
      let(:all) { presenter_object.codicology_terms.keys.length }
      let(:missing) { presenter_object_missing_items.codicology_terms.keys.length }

      it "returns existing keys" do
        expect(all).to eq 17
        expect(config.length).to eq all
      end

      it "is missing elements" do
        expect(all - missing).to_not eq 0
        expect(config.length - missing).to_not eq 0
      end
    end
  end
end
