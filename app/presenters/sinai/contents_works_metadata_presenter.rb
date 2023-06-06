# frozen_string_literal: true
module Sinai
  class ContentsWorksMetadataPresenter
    attr_reader :document

    def initialize(document:)
      @document = document
      @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata-sinai/contents_works_metadata.yml')))
    end

    def contents_terms
      @document.slice(*@config.keys)
    end
  end
end
