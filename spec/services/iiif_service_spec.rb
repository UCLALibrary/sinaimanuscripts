# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifService do
  let(:service) { described_class.new }
  let(:solr_document) do
    SolrDocument.new(id: 'abc123',
                     iiif_manifest_url_ssi: 'https://manifest.store/ark%3A%2Fabc%2F123/manifest')
  end
  let(:solr_document_with_cv) do
    SolrDocument.new(id: 'cde123',
                     iiif_manifest_url_ssi: 'https://manifest.store/ark%3A%2Fabc%2F123/manifest',
                     member_ids_ssim: 7)
  end

  before do
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://californica.url/concern/works')
  end

  describe '#iiif_manifest_url' do
    context 'when a url is stored and feature enabled' do
      it 'uses that url' do
        allow(Flipflop).to receive(:use_manifest_store?).and_return(true)

        expect(service.iiif_manifest_url(solr_document)).to eq 'https://manifest.store/ark%3A%2Fabc%2F123/manifest'
      end
    end

    xcontext 'when a url is stored but feature is disabled' do
      it 'builds a local url' do
        allow(Flipflop).to receive(:use_manifest_store?).and_return(false)

        expect(service.iiif_manifest_url(solr_document)).to eq 'https://californica.url/concern/works/abc123/manifest'
      end
    end

    xcontext 'when nothing is stored' do
      let(:solr_document) { SolrDocument.new(id: 'abc123') }

      it 'builds a local url' do
        allow(Flipflop).to receive(:use_manifest_store?).and_return(true)

        expect(service.iiif_manifest_url(solr_document)).to eq 'https://californica.url/concern/works/abc123/manifest'
      end
    end
  end

  describe '#src' do
    before do
      allow(Flipflop).to receive(:use_manifest_store?).and_return(true)
      allow(request).to receive(:query_parameters).and_return({})
    end

    let(:request) { instance_double('ActionDispatch::Request', base_url: 'http://test.url') }

    it 'links to mirador' do
      allow(Flipflop).to receive(:sinai?).and_return(true)

      expect(service.src(request, solr_document)).to eq 'https://p-w-dl-viewer01.library.ucla.edu/?site=sinai&manifest=https%3A%2F%2Fmanifest.store%2Fark%253A%252Fabc%252F123%2Fmanifest'
    end
  end
end
