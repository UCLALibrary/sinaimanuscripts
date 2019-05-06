# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Ursus::SecondaryMetadataPresenter do
  let(:id) { '123' }
  let(:pres) { described_class.new(document: doc) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'secondary_metadata.yml'))) }
  let(:doc) do
    { "title_tesim" => { "key" => "title_tesim", "field" => "title_tesim", "label" => "Title Tesim", "if" => true, "unless" => false }, "description_tesim" => { "separator_options" => { "words_connector" => "<br/>", "two_words_connector" => "<br/>", "last_word_connector" => "<br/>" }, "key" => "description_tesim", "field" => "description_tesim", "label" => "Description Tesim", "if" => true, "unless" => false }, "subject_tesim" => { "link_to_facet" => "subject_sim", "separator_options" => { "words_connector" => "<br/>", "two_words_connector" => "<br/>", "last_word_connector" => "<br/>" }, "key" => "subject_tesim", "field" => "subject_tesim", "label" => "Subject Tesim", "if" => true, "unless" => false }, "publisher_tesim" => { "key" => "publisher_tesim", "field" => "publisher_tesim", "label" => "Publisher Tesim", "if" => true, "unless" => false }, "language_tesim" => { "link_to_facet" => "language_sim", "key" => "language_tesim", "field" => "language_tesim", "label" => "Language Tesim", "if" => true, "unless" => false }, "date_created_tesim" => { "key" => "date_created_tesim", "field" => "date_created_tesim", "label" => "Date Created Tesim", "if" => true, "unless" => false }, "human_readable_rights_statement_tesim" => { "key" => "human_readable_rights_statement_tesim", "field" => "human_readable_rights_statement_tesim", "label" => "Human Readable Rights Statement Tesim", "if" => true, "unless" => false }, "resource_type_tesim" => { "label" => "Resource Type", "link_to_facet" => "resource_type_sim", "key" => "resource_type_tesim", "field" => "resource_type_tesim", "if" => true, "unless" => false }, "identifier_tesim" => { "key" => "identifier_tesim", "field" => "identifier_tesim", "label" => "Identifier Tesim", "if" => true, "unless" => false }, "extent_tesim" => { "key" => "extent_tesim", "field" => "extent_tesim", "label" => "Extent Tesim", "if" => true, "unless" => false }, "genre_tesim" => { "link_to_facet" => "genre_sim", "separator_options" => { "words_connector" => "<br/>", "two_words_connector" => "<br/>", "last_word_connector" => "<br/>" }, "key" => "genre_tesim", "field" => "genre_tesim", "label" => "Genre Tesim", "if" => true, "unless" => false }, "location_tesim" => { "link_to_facet" => "location_sim", "key" => "location_tesim", "field" => "location_tesim", "label" => "Location Tesim", "if" => true, "unless" => false }, "local_identifier_ssm" => { "key" => "local_identifier_ssm", "field" => "local_identifier_ssm", "label" => "Local identifier Tesim", "if" => true, "unless" => false }, "named_subject_tesim" => { "link_to_facet" => "named_subject_sim", "separator_options" => { "words_connector" => "<br/>", "two_words_connector" => "<br/>", "last_word_connector" => "<br/>" }, "key" => "named_subject_tesim", "field" => "named_subject_tesim", "label" => "Named Subject Tesim", "if" => true, "unless" => false }, "repository_tesim" => { "key" => "repository_tesim", "field" => "repository_tesim", "label" => "Repository Tesim", "if" => true, "unless" => false }, "rights_country_tesim" => { "key" => "rights_country_tesim", "field" => "rights_country_tesim", "label" => "Rights Country Tesim", "if" => true, "unless" => false }, "rights_holder_tesim" => { "key" => "rights_holder_tesim", "field" => "rights_holder_tesim", "label" => "Rights Holder Tesim", "if" => true, "unless" => false } } # rubocop:disable Metrics/LineLength
  end

  context 'with a solr document containing secondary metadata' do
    describe '#terms' do
      it 'returns a hash that only has the secondary metadata' do
        expect(pres.terms).not_to include('title_tesim')
      end
    end
  end
end
