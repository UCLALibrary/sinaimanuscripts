# frozen_string_literal: true
module Sinai
  class KeywordsMetadataPresenter < BaseMetadataPresenter
    self.config_file = 'metadata-sinai/keywords_metadata.yml'

    def keywords_terms
      fields_to_render_by_config_keys
    end
  end
end
